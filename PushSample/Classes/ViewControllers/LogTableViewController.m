//
//  Copyright (C) 2014 - 2016 Pivotal Software, Inc. All rights reserved. 
//  
//  This program and the accompanying materials are made available under 
//  the terms of the under the Apache License, Version 2.0 (the "License”); 
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <PCFPush/PCFPushDebug.h>
#import <PCFPush/PCFPushPersistentStorage.h>
#import <CoreLocation/CoreLocation.h>
#import <PCFPush/PCFPush.h>
#import "LogItem.h"
#import "LogItemCell.h"
#import "LogTableViewController.h"
#import "BackEndMessageRequest.h"
#import "Settings.h"
#import "PCFPushGeofencePersistentStore.h"
#import "PCFPushGeofenceRegistrar.h"
#import "AppDelegate.h"

#define ACTION_SHEET_ACTIONS            0
#define ACTION_SHEET_SEND               1
#define ACTION_SHEET_SEND_TO_TAG        2
#define ACTION_SHEET_SUBSCRIBE_TO_TAG   3

#define ALERT_SEND_CUSTOM_USER_ID       0
#define ALERT_SET_CUSTOM_USER_ID        1

@interface LogTableViewController ()

@property (nonatomic) NSMutableArray *logItems;
@property (nonatomic) NSArray *availableTags;

@end

@implementation LogTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Setup cells for loading into table view
    UINib *nib = [UINib nibWithNibName:LOG_ITEM_CELL bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:LOG_ITEM_CELL];

    // Don't let the view appear under the status bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.availableTags = @[ @"ALPHA", @"BETA", @"GAMMA", @"OMEGA" ];

    // Listen for push messages to get posted to the debug log so that we
    // can echo them to the display.
    [PCFPushDebug setLogListener:^(NSString *message, NSDate *timestamp) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self addLogItem:message timestamp:timestamp];
        }];
    }];

    // Set up tool bar buttons
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendOptionsButtonPressed)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *moreActions = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreActionsPressed)];
    [self setToolbarItems:@[sendButton, space, moreActions] animated:NO];

    [self addLogItem:@"Press the \"Send\" button below to send a push message via the back-end server." timestamp:[NSDate date]];
    [self addLogItem:@"Press the \"Send with Tags\" button in the actions menu to send a push message with some tags via the back-end server." timestamp:[NSDate date]];
    [self addLogItem:@"Press the \"Send with Category\" button in the actions menu to send a push message with a category via the back-end server." timestamp:[NSDate date]];

    [self updateCurrentBaseRowColour];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geofenceStatusChanged:) name:PCF_PUSH_GEOFENCE_STATUS_UPDATE_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) copyButtonPressed
{
    [self copyEntireLog];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copied entire log to clipboard."
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) sendOptionsButtonPressed
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Send Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send Push", @"Send to Tag", @"Send with Category", @"Send to Custom User ID", nil];

    sheet.tag = ACTION_SHEET_SEND;

    [sheet showInView:UIApplication.sharedApplication.keyWindow];
}

- (void) moreActionsPressed
{
    NSString *geofenceOption;
    if ([Settings areGeofencesEnabled]) {
        geofenceOption = @"Disable geofences";
    } else {
        geofenceOption = @"Enable geofences";
    }

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Copy Log", @"Clear Log", @"Unregistration", @"Subscribe to Tag", @"Unsubscribe from Tag", @"Set Custom User ID", geofenceOption, @"About", nil];

    sheet.tag = ACTION_SHEET_ACTIONS;

    [sheet showInView:UIApplication.sharedApplication.keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (popup.tag == ACTION_SHEET_ACTIONS) {
        switch (buttonIndex) {
            case 0: [self copyButtonPressed]; break;
            case 1: [self clearLogPressed]; break;
            case 2: [self unregistrationPressed]; break;
            case 3: [self subscribeToTag]; break;
            case 4: [self unsubscribeFromTag]; break;
            case 5: [self showCustomUserIdInputBox:ALERT_SET_CUSTOM_USER_ID]; break;
            case 6: [self toggleGeofences]; break;
            case 7: [self aboutPressed]; break;
            default: break;
        }

    } else if (popup.tag == ACTION_SHEET_SEND) {
        switch (buttonIndex) {
            case 0: [self sendPushPressed]; break;
            case 1: [self sendWithTagPressed]; break;
            case 2: [self sendWithCategoryPressed]; break;
            case 3: [self sendWithCustomUserIdPressed]; break;
            default: break;
        }

    } else if (popup.tag == ACTION_SHEET_SEND_TO_TAG && buttonIndex < self.availableTags.count) {
        [self sendMessageWithCategory:nil tag:self.availableTags[(NSUInteger) buttonIndex] customUserIds:nil];

    } else if (popup.tag == ACTION_SHEET_SUBSCRIBE_TO_TAG && buttonIndex < self.availableTags.count) {
        [self subscribeToTag:self.availableTags[(NSUInteger) buttonIndex]];
    }
}

- (void)subscribeToTag:(NSString *)tag
{
    [self updateCurrentBaseRowColour];
    [PCFPush subscribeToTags:[NSSet setWithObject:tag] success:^{
        PCFPushLog(@"Successfully subscribed to tag '%@'", tag);
        Settings.tag = tag;

    } failure:^(NSError *error) {
        PCFPushLog(@"Failed to subscribe to tag '%@': %@", tag, error);

    }];
}

- (void)unsubscribeFromTag
{
    [self updateCurrentBaseRowColour];
    if (!Settings.tag) {
        PCFPushLog(@"Not currently subscribed to any tags.");
    } else {
        [PCFPush subscribeToTags:[NSSet set] success:^{
            PCFPushLog(@"Successfully unsubscribed from tags.");
            Settings.tag = nil;
        } failure:^(NSError *error) {
            PCFPushLog(@"Error unsubscribing from tags: %@", error);
        }];
    }
}

- (void)unregistrationPressed
{
    [self updateCurrentBaseRowColour];
    [PCFPush unregisterFromPCFPushNotificationsWithSuccess:^{
        PCFPushLog(@"Successfully unregistered.");
    } failure:^(NSError *error) {
        PCFPushLog(@"Error unregistering: %@", error);
    }];
}

- (void) copyEntireLog
{
    NSMutableString *s = [NSMutableString string];
    for (LogItem *logItem in self.logItems) {
        [s appendString:[NSString stringWithFormat:@"%@\t%@\n", logItem.timestamp, logItem.message]];
    }
    [self copyStringToPasteboard:s];
}

- (void) toggleGeofences
{
    [self updateCurrentBaseRowColour];
    BOOL areGeofencesEnabled = !Settings.areGeofencesEnabled;
    if (areGeofencesEnabled) {
        PCFPushLog(@"Enabling geofences...");
    } else {
        PCFPushLog(@"Disabling geofences...");
    }

    [PCFPush setAreGeofencesEnabled:areGeofencesEnabled success:^{
        PCFPushLog(@"Registering after successfully setting areGeofencesEnabled");
        [Settings setAreGeofencesEnabled:areGeofencesEnabled];
    } failure:^(NSError *error) {
        PCFPushLog(@"Failed to set areGeofencesEnabled parameter: %@", error);
    }];
}

- (void) aboutPressed
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *message = [@"PCF Push version " stringByAppendingString:version];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"PCF Push Test" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void) copyStringToPasteboard:(NSString*)s
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.persistent = YES;
    [pb setString:s];
}

- (void)clearLogPressed
{
    self.logItems = [NSMutableArray array];
    [self.tableView reloadData];
}

- (void) updateCurrentBaseRowColour
{
    [LogItem updateBaseColour];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

- (void) addLogItem:(NSString*)message timestamp:(NSDate*)timestamp
{
    if (!self.logItems) {
        self.logItems = [NSMutableArray array];
    }
    LogItem *logItem = [[LogItem alloc] initWithMessage:message timestamp:timestamp];
    [self.logItems addObject:logItem];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.logItems.count-1) inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void) subscribeToTag
{
    NSString *currentTag = Settings.tag;

    NSString *message;
    if (currentTag) {
        message = [NSString stringWithFormat:@"Select a tag to SUBSCRIBE to (currently subscribed to '%@'):", currentTag];
    } else {
        message = @"Select a tag to SUBSCRIBE to (currently subscribed to no tags):";
    }

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:self.availableTags[0], self.availableTags[1], self.availableTags[2], self.availableTags[3], nil];

    sheet.tag = ACTION_SHEET_SUBSCRIBE_TO_TAG;

    [sheet showInView:UIApplication.sharedApplication.keyWindow];
}

- (void) geofenceStatusChanged:(NSNotification*)notification
{
    PCFPushGeofenceStatus *status = [PCFPush geofenceStatus];
    PCFPushLog(@"%@", status);
}

#pragma mark - Custom User ID

- (void) showCustomUserIdInputBox:(NSUInteger)tag
{
    NSString *message;
    NSString *currentCustomUserId = [Settings customUserId];
    NSArray *otherButtons;
    NSString *defaultTextFieldContents = nil;

    if (tag == ALERT_SEND_CUSTOM_USER_ID) {

        if (!currentCustomUserId || currentCustomUserId.length == 0) {
            message = @"There is no custom user ID currently set on this device.\n\nYou can target multiple custom user IDs by separating them with commas. Please note that custom user IDs are case-sensitive.";
        } else {
            message = [NSString stringWithFormat:@"The current custom user ID for this device is '%@'.\n\nYou can target multiple custom user IDs by separating them with commas. Please note that custom user IDs are case-sensitive.", currentCustomUserId];
            defaultTextFieldContents = currentCustomUserId;
        }

        otherButtons = @[ @"Send" ];

    } else if (tag == ALERT_SET_CUSTOM_USER_ID) {

        if (!currentCustomUserId || currentCustomUserId.length == 0) {
            message = @"There is no custom user ID currently set. Please enter a new custom user ID:";
        } else {
            message = [NSString stringWithFormat:@"The current custom user ID for this device is '%@'. Please enter a new custom user ID to register:", currentCustomUserId];
        }

        otherButtons = @[ @"Set", @"Clear" ];

    } else {
        return;
    }

    UIAlertView *customUserIdView = [[UIAlertView alloc] initWithTitle:@"Custom User ID" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    customUserIdView.alertViewStyle = UIAlertViewStylePlainTextInput;
    customUserIdView.tag = tag;
    for (NSString *otherButton in otherButtons) {
        [customUserIdView addButtonWithTitle:otherButton];
    }

    [customUserIdView show];

    if (defaultTextFieldContents) {
        UITextField *textField = [customUserIdView textFieldAtIndex:0];
        textField.placeholder = defaultTextFieldContents;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return; // Cancel button pressed
    }

    UITextField *customUserIdTextField = [alertView textFieldAtIndex:0];

    NSString *customUserIdText = [customUserIdTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    if (alertView.tag == ALERT_SEND_CUSTOM_USER_ID) {

        if (!customUserIdText || customUserIdText.length <= 0) {
            NSString *currentCustomUserId = [Settings customUserId];
            if (!currentCustomUserId || currentCustomUserId.length <= 0)
            {
                UIAlertView *hogey = [[UIAlertView alloc] initWithTitle:@"Lo, Hogey!" message:@"You cannot push to an empty custom user ID." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK, SORRY", nil];
                [hogey show];
                return;
            }
            customUserIdText = currentCustomUserId;
        }

        [self addLogItem:[NSString stringWithFormat:@"Sending push notification to custom user ID '%@'.", customUserIdText] timestamp:NSDate.date];
        NSArray *customUserIds = [self customUserIdsFromCommaDelimitedString:customUserIdText];
        [self sendMessageWithCategory:nil tag:nil customUserIds:customUserIds];

    } else if (alertView.tag == ALERT_SET_CUSTOM_USER_ID) {

        NSString *customUserIdToSet = nil;

        if (buttonIndex == 1) { // Set button
            customUserIdToSet = customUserIdText;
        }

        if (customUserIdToSet) {
            [self addLogItem:[NSString stringWithFormat:@"Setting to custom user ID to '%@'.", customUserIdText] timestamp:NSDate.date];
        } else {
            [self addLogItem:@"Clearing current custom user ID." timestamp:NSDate.date];
        }

        [self updateCurrentBaseRowColour];

        [Settings setCustomUserId:customUserIdToSet];

        [AppDelegate startRegistration];

    } else {
        return;
    }
}

#pragma mark - Sending Messages

- (void) sendPushPressed
{
    [self sendMessageWithCategory:nil tag:nil customUserIds:nil];
}

- (void) sendWithTagPressed
{
    NSString *currentTag = Settings.tag;

    NSString *message;
    if (currentTag) {
        message = [NSString stringWithFormat:@"Select a tag to PUSH to (currently subscribed to '%@'):", currentTag];
    } else {
        message = @"Select a tag to PUSH to (currently subscribed to no tags):";
    }

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:self.availableTags[0], self.availableTags[1], self.availableTags[2], self.availableTags[3], nil];

    sheet.tag = ACTION_SHEET_SEND_TO_TAG;

    [sheet showInView:UIApplication.sharedApplication.keyWindow];
}

- (void) sendWithCategoryPressed
{
    [self sendMessageWithCategory:@"ACTIONABLE" tag:nil customUserIds:nil];
}

- (void) sendWithCustomUserIdPressed
{
    [self showCustomUserIdInputBox:ALERT_SEND_CUSTOM_USER_ID];
}

- (void)sendMessageWithCategory:(NSString *)category tag:(NSString *)tag customUserIds:(NSArray *)customUserIds
{
    [self updateCurrentBaseRowColour];
    NSString *backEndDeviceID = [PCFPushPersistentStorage serverDeviceID];

    if (backEndDeviceID == nil) {
        [self addLogItem:@"You must register with the back-end server before attempting to send a message" timestamp:[NSDate date]];
        return;
    }
    // Prepare a request that is used to request a push message from the Pivotal CF Mobile Services push server.
    // This feature is NOT a feature of the Push Client SDK but is useful for helping debug.
    BackEndMessageRequest *request = [[BackEndMessageRequest alloc] init];
    request.messageBody = [self messageForTag:tag customUserIds:customUserIds];
    request.appUuid = APP_UUID;
    request.apiKey = API_KEY;
    request.targetDevices = @[backEndDeviceID];
    request.category = category;
    if (tag) {
        request.tags = [NSSet setWithObject:tag];
    }
    if (customUserIds) {
        request.customUserIds = customUserIds;
    }
    [request sendMessage];
}

- (NSArray *) customUserIdsFromCommaDelimitedString:(NSString *)string{
    NSArray *customUserIds = [string componentsSeparatedByString:@","];
    NSMutableArray *trimmedCustomUserIds = [NSMutableArray array];
    for (NSString *s in customUserIds) {
        [trimmedCustomUserIds addObject:[s stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]];
    }
    return trimmedCustomUserIds;
}

- (NSString *) messageForTag:(NSString *)tag customUserIds:(NSArray *)customUserIds
{
    NSString *date = [[LogItem getDateFormatter] stringFromDate:NSDate.date];

    if (tag.length > 0 && customUserIds.count > 0) {
        return [NSString stringWithFormat:@"This message was sent to tag '%@' and custom user ID(s) '%@' at %@.", tag, [customUserIds componentsJoinedByString:@", "], date];
    } else if (tag.length > 0) {
        return [NSString stringWithFormat:@"This message was sent to tag '%@' at %@.", tag, date];
    } else if (customUserIds.count > 0) {
        return [NSString stringWithFormat:@"This message was sent to custom user ID(s) '%@' at %@.", [customUserIds componentsJoinedByString:@", "], date];
    } else {
        return [NSString stringWithFormat:@"This message was sent to this device at %@.", date];
    }
 }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogItemCell *cell = [tableView dequeueReusableCellWithIdentifier:LOG_ITEM_CELL forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LogItem *logItem = (LogItem*) self.logItems[(NSUInteger)indexPath.row];
    [cell setLogItem:logItem containerSize:self.view.frame.size];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogItem *item = self.logItems[(NSUInteger)indexPath.row];
    CGFloat height = [LogItemCell heightForCellWithText:item.message containerSize:self.view.frame.size];
    return height;
}

@end
