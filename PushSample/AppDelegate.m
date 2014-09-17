//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <MSSPush/MSSPush.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPushPersistentStorage.h>
#import <MSSPush/MSSPushDebug.h>

@interface AppDelegate ()

@property (nonatomic) BOOL registered;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Push notifications are automatically registered at start up.
    // The parameters are stored in the file "MSSParameters.plist".
    //
    // Note that if the "pushAutoRegistrationEnabled" file in the plist file
    // is set to "NO" then automatic registration will be disabled.
    //
    // In that case, you can register manually by preparing an "MSSParameters"
    // object with your particular settings, passing it to [MSSPush setRegistrationParameters],
    // and then calling [MSSPush registerForPushNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    MSSPushLog(@"Received message: %@", userInfo[@"aps"][@"alert"]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    MSSPushLog(@"FetchCompletionHandler Received message: %@", userInfo[@"aps"][@"alert"]);
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - UIApplicationDelegate Push Notification Callback

- (void) application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    MSSPushLog(@"Received message: didRegisterForRemoteNotificationsWithDeviceToken:");
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    MSSPushLog(@"Received message: didFailToRegisterForRemoteNotificationsWithError:");
}

@end
