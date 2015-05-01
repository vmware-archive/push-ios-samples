//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPushDebug.h>
#import <PCFPush/PCFPushPersistentStorage.h>
#import <CoreLocation/CoreLocation.h>
#import "LogItem.h"
#import "LogItemCell.h"
#import "LogTableViewController.h"
#import "BackEndMessageRequest.h"
#import "Settings.h"
#import "PCFPushGeofencePersistentStore.h"
#import "PCFPushGeofenceRegistrar.h"

@interface LogTableViewController ()

@property (nonatomic) NSMutableArray *logItems;

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

    // Listen for push messages to get posted to the debug log so that we
    // can echo them to the display.
    [PCFPushDebug setLogListener:^(NSString *message, NSDate *timestamp) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self addLogItem:message timestamp:timestamp];
        }];
    }];

    // Set up tool bar buttons
    UIBarButtonItem *sendButtonWithoutCategory = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonWithoutCategoryPressed)];
    UIBarButtonItem *sendButtonWithCategory = [[UIBarButtonItem alloc] initWithTitle:@"Send w/Category" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonWithCategoryPressed)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *moreActions = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreActionsPressed)];

    [self setToolbarItems:@[sendButtonWithoutCategory, space, sendButtonWithCategory, space, moreActions] animated:NO];

    [self addLogItem:@"Press the \"Send\" button below to send a push message via the back-end server." timestamp:[NSDate date]];
    [self addLogItem:@"Press the \"Send w/Cat.\" button below to send a push message with a category via the back-end server." timestamp:[NSDate date]];

    [self updateCurrentBaseRowColour];
}

- (void) sendButtonWithCategoryPressed
{
    [self sendMessageWithCategory:@"ACTIONABLE"];
}

- (void) sendButtonWithoutCategoryPressed
{
    [self sendMessageWithCategory:nil];
}

- (void) sendMessageWithCategory:(NSString*)category
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
    request.messageBody = [NSString stringWithFormat:@"This message was sent to the back-end at %@.", [[LogItem getDateFormatter] stringFromDate:[NSDate date]]];
    request.appUuid = APP_UUID;
    request.apiKey = API_KEY;
    request.targetDevices = @[backEndDeviceID];
    request.category = category;
    [request sendMessage];
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

- (void) moreActionsPressed
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Copy Log", @"Clear Log", @"Clear Registration", nil];

    [sheet showInView:UIApplication.sharedApplication.keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self copyButtonPressed];
            break;
        case 1:
            [self clearLogPressed];
            break;
        case 2:
            [self clearRegistrationPressed];
            break;
        default:
            break;
    }
}

- (void)clearRegistrationPressed
{
    PCFPushGeofencePersistentStore *store = [[PCFPushGeofencePersistentStore alloc] initWithFileManager:NSFileManager.defaultManager];
    [store reset];
    PCFPushGeofenceRegistrar *registrar = [[PCFPushGeofenceRegistrar alloc] initWithLocationManager:[[CLLocationManager alloc] init]];
    [registrar reset];
    [PCFPushPersistentStorage reset];
}

- (void) copyEntireLog
{
    NSMutableString *s = [NSMutableString string];
    for (LogItem *logItem in self.logItems) {
        [s appendString:[NSString stringWithFormat:@"%@\t%@\n", logItem.timestamp, logItem.message]];
    }
    [self copyStringToPasteboard:s];
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
