//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import <PCFPush/PCFParameters.h>
#import <PCFPush/PCFPushDebug.h>
#import "AppDelegate.h"

NSString * const kNotificationCategoryIdent  = @"ACTIONABLE";
NSString * const kNotificationActionOneIdent = @"ACTION_ONE";
NSString * const kNotificationActionTwoIdent = @"ACTION_TWO";

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // The parameters are stored in the file "PCFParameters.plist".
    
    // If running on iOS 7.1 or less, then you must precede the call to [PCFPush setRegistrationParameters]
    // with a call to [PCFPush setRemoteNotificationTypes:] with your requested user notification types.
    //
    // On iOS 8.0+ you should call [[UIApplication sharedDelegate] registerUserNotificationSettings:] to
    // configure your user notifications
    
    // If this line gives you a compiler error then you need to make sure you have updated
    // your Xcode to at least Xcode 6.0:

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                
        // iOS 8.0 +
        // Note that all of these notifications types are implicitly opted-in on iOS 8.0+ anyways.
        [application registerUserNotificationSettings:[self getUserNotificationSettings]];
        
    } else {
        
        // < iOS 8.0
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [PCFPush setRemoteNotificationTypes:notificationTypes];
    }

    [PCFPush setDeviceAlias:UIDevice.currentDevice.name];

    // [PCFPush registerForRemoteNotifications] is called from the LogTableViewController since we want to be able to
    // print the registration results to the screen.

    return YES;
}

- (UIUserNotificationSettings*) getUserNotificationSettings
{
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Action 1"];
    [action1 setIdentifier:kNotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Action 2"];
    [action2 setIdentifier:kNotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:kNotificationCategoryIdent];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    return [UIUserNotificationSettings settingsForTypes:types
                                             categories:categories];
}

#pragma mark - Handling remote notifications

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self handleRemoteNotification:userInfo];
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void) handleRemoteNotification:(NSDictionary*) userInfo
{
    if (userInfo) {
        PCFPushLog(@"Received push message: %@", userInfo);
    } else {
        PCFPushLog(@"Received push message (no userInfo).");
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    PCFPushLog(@"Handling action %@ for message %@", identifier, userInfo);
    if (completionHandler) {
        completionHandler();
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - UIApplicationDelegate remote registration callbacks

// This message is called when APNS registration succeeds.  Note that it is still possible for
// registration with Pivotal CF Mobile Services to fail after this message is received.
- (void) application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PCFPushLog(@"APNS registration succeeded!");
}

// This message is called when APNS registration fails.
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    PCFPushLog(@"APNS registration failed: %@", err);
}

@end
