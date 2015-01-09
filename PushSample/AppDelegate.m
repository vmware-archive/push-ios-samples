//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import <PCFPush/PCFParameters.h>
#import <PCFPush/PCFPushPersistentStorage.h>
#import <PCFPush/PCFPushDebug.h>
#import "AppDelegate.h"

NSString * const kNotificationCategoryIdent  = @"ACTIONABLE";
NSString * const kNotificationActionOneIdent = @"ACTION_ONE";
NSString * const kNotificationActionTwoIdent = @"ACTION_TWO";

@interface AppDelegate ()

@property (nonatomic) BOOL registered;

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Push notifications are automatically registered at start up.
    // The parameters are stored in the file "PCFParameters.plist".
    //
    // Note that if the "pushAutoRegistrationEnabled" file in the plist file
    // is set to "NO" then automatic registration will be disabled.
    //
    // In that case, you can register manually by preparing an "PCFParameters"
    // object with your particular settings, passing it to [PCFPush setRegistrationParameters],
    // and then calling [PCFPush registerForPushNotifications];
    
    // If running on iOS 7.1 or less, then you must precede the call to [PCFPush setRegistrationParameters]
    // with a call to [PCFPush setRemoteNotificationTypes:] with your requested user notification types.
    //
    // On iOS 8.0+ you should call [[UIApplication sharedDelegate] registerUserNotificationSettings:] to
    // configure your user notifications
    
    // If this line gives you a compiler error then you need to make sure you have updated
    // your Xcode to at least Xcode 6.0:
    
    [self getPushRuntimeArguments];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                
        // iOS 8.0 +
        // Note that all of these notifications types are implicitly opted-in on iOS 8.0+ anyways.
        [application registerUserNotificationSettings:[self getUserNotificationSettings]];
        
    } else {
        
        // < iOS 8.0
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [PCFPush setRemoteNotificationTypes:notificationTypes];
    }
    
    return YES;
}

- (void)getPushRuntimeArguments {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushApiUrl = [standardDefaults stringForKey:@"pushApiUrl"];
    if (pushApiUrl) {
        PCFParameters *parameters = [[PCFParameters alloc] init];
        parameters.pushAPIURL = pushApiUrl;
        parameters.pushDeviceAlias = [standardDefaults stringForKey:@"pushDeviceAlias"];
        parameters.pushAutoRegistrationEnabled = [standardDefaults boolForKey:@"pushAutoRegistrationEnabled"];
        
        parameters.productionPushVariantUUID = [standardDefaults stringForKey:@"productionPushVariantUUID"];
        parameters.developmentPushVariantUUID = [standardDefaults stringForKey:@"developmentPushVariantUUID"];
        
        parameters.productionPushVariantSecret = [standardDefaults stringForKey:@"productionPushVariantSecret"];
        parameters.developmentPushVariantSecret = [standardDefaults stringForKey:@"developmentPushVariantSecret"];
        
        [PCFPush setRegistrationParameters:parameters];
    }
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
