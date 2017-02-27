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

#import <CoreLocation/CoreLocation.h>
#import <PCFPush/PCFPush.h>
#import <PCFPush/PCFPushDebug.h>
#import "AppDelegate.h"
#import "Settings.h"

NSString * const kNotificationCategoryIdent  = @"ACTIONABLE";
NSString * const kNotificationActionOneIdent = @"ACTION_ONE";
NSString * const kNotificationActionTwoIdent = @"ACTION_TWO";

@interface AppDelegate()

// Required to monitor geofences on iOS 8.0+
@property (nonatomic) CLLocationManager *locationManager;

@end

void runStartPushRegistrationWithServiceInfo(PCFPushServiceInfo *serviceInfo)
{
    [PCFPush setPushServiceInfo:serviceInfo];
    [AppDelegate startRegistration];
}

@implementation AppDelegate

+ (void) startRegistration
{
    [UIApplication.sharedApplication.delegate application:UIApplication.sharedApplication didFinishLaunchingWithOptions:nil];
}

+ (void) startRegistrationWithApiUrl:(NSString *)apiUrl
                        platformUuid:(NSString *)platformUuid
                      platformSecret:(NSString *)platformSecret
{
    PCFPushServiceInfo *serviceInfo = [[PCFPushServiceInfo alloc] initWithApi:apiUrl
                                                              devPlatformUuid:platformUuid
                                                            devPlatformSecret:platformSecret
                                                             prodPlatformUuid:platformUuid
                                                           prodPlatformSecret:platformSecret];
    
    [PCFPush unregisterFromPCFPushNotificationsWithSuccess:^{
        PCFPushLog(@"Unregistration success");
        runStartPushRegistrationWithServiceInfo(serviceInfo);
    } failure:^(NSError *error) {
        PCFPushLog(@"Unregistration failed: %@", error);
        runStartPushRegistrationWithServiceInfo(serviceInfo);
    }];
    
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register for push notifications with the Apple Push Notification Service (APNS).
    //
    // On iOS 8.0+ you need to provide your user notification settings by calling
    // [UIApplication.sharedDelegate registerUserNotificationSettings:] and then
    // [UIApplication.sharedDelegate registerForRemoteNotifications].
    //
    // On iOS 10.0 you may use the new UserNotifications framework to configure your notification settings, but you
    // will still need to use the [UIApplication registerForRemoteNotifications method in order to register for remote
    // notifications with APNS.  Note that the older [UIApplication registerUserNotificationSettings:] method continues
    // to work on iOS 10.0, even if it is deprecated.

    [application registerUserNotificationSettings:[self getUserNotificationSettings]];
    [application registerForRemoteNotifications];

    // Required before geofences can be monitored on iOS 8.0+
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];

    return YES;
}

#pragma mark - UIApplicationDelegate remote registration callbacks

// This method is called when APNS registration succeeds.
- (void) application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PCFPushLog(@"APNS registration succeeded!");

    // APNS registration has succeeded and provided the APNS device token.  Start registration with PCF Mobile Services
    // and pass it the APNS device token.
    //
    // Required: Create a file in your project called "Pivotal.plist" in order to provide parameters for registering with
    // PCF Mobile Services.
    //
    // Optional: You can also provide a set of tags to subscribe to.  At this time, this application is not setting any tags.
    //
    // Optional: You can also provide a device alias.  The use of this device alias is application-specific.  In general,
    // you can pass the device name.
    //
    // Optional: You can pass blocks to get callbacks after registration succeeds or fails.
    //
    NSSet *tags = nil;
    if (Settings.tag) {
        tags  = [NSSet setWithObject:Settings.tag];
    }
    
    [PCFPush registerForPCFPushNotificationsWithDeviceToken:deviceToken
                                                       tags:tags
                                                deviceAlias:UIDevice.currentDevice.name
                                               customUserId:Settings.customUserId
                                        areGeofencesEnabled:Settings.areGeofencesEnabled
                                                    success:^{
        PCFPushLog(@"CF registration succeeded. The Device UUID is \"%@\".", [PCFPush deviceUuid]);
    } failure:^(NSError *error) {
        PCFPushLog(@"CF registration failed: %@", error);
    }];

}

// This method is called when APNS registration fails.
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    PCFPushLog(@"APNS registration failed: %@", error);
}

#pragma mark - Handling remote notifications

// This method is called when APNS sends a push notification to the application.
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleRemoteNotification:userInfo];
}

// This method is called when APNS sends a push notification to the application when the application is
// not running (e.g.: in the background).
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self handleRemoteNotification:userInfo];

    [PCFPush didReceiveRemoteNotification:userInfo completionHandler:^(BOOL wasIgnored, UIBackgroundFetchResult fetchResult, NSError *error) {

        if (completionHandler) {
            completionHandler(fetchResult);
        }
    }];
}

- (void) handleRemoteNotification:(NSDictionary*) userInfo
{
    if (userInfo) {
        PCFPushLog(@"Received push message: %@", userInfo);
    } else {
        PCFPushLog(@"Received push message (no userInfo).");
    }
}

// This method is called when the user touches one of the actions in a notification when the application is
// not running (e.g.: in the background).  iOS 8.0+ only.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    PCFPushLog(@"Handling action %@ for message %@", identifier, userInfo);
    if (completionHandler) {
        completionHandler();
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Clear the badge number displayed on the application icon.
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - Handling local notifications

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    PCFPushLog(@"Received %@ local notification '%@'", notification.userInfo[@"pivotal.push.geofence_trigger_condition"], notification.alertBody);
    NSNotification *n = [NSNotification notificationWithName:@"pivotal.push.demo.localnotification" object:notification];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

#pragma mark - Helpers

// Returns the user notification settings object used on iOS 8.0 +
// This code will still run on iOS 10.0, but you can migrate to the UserNotifications framework if you want.
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

@end
