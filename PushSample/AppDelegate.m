//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <MSSPush/MSSPush.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPushPersistentStorage.h>
#import <MSSPush/MSSPushDebug.h>
#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic) BOOL registered;

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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

    // If running on iOS 7.1 or less, then you must precede the call to [MSSPush setRegistrationParameters]
    // with a call to [MSSPush setRemoteNotificationTypes:] with your requested user notification types.
    //
    // On iOS 8.0+ you should call [[UIApplication sharedDelegate] registerUserNotificationSettings:] to
    // configure your user notifications
    
    // If this line gives you a compiler error then you need to make sure you have updated
    // your Xcode to at least Xcode 6.0:

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // iOS 8.0 +
        // Note that all of these notifications types are implicitly opted-in on iOS 8.0+ anyways.
        UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        
    } else {
        
        // < iOS 8.0
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [MSSPush setRemoteNotificationTypes:notificationTypes];
    }
    
    return YES;
}

#pragma mark - Handling remote notifications

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void) handleRemoteNotification:(NSDictionary*) userInfo
{
    if (userInfo[@"aps"][@"alert"]) {
        MSSPushLog(@"Received remote message: %@", userInfo[@"aps"][@"alert"]);
    } else {
        MSSPushLog(@"Received remote message.");
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
    MSSPushLog(@"APNS registration succeeded!");
}

// This message is called when APNS registration fails.
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    MSSPushLog(@"APNS registration failed: %@", err);
}

@end
