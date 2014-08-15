//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import <MSSPush/MSSPush.h>
#import <MSSPush/MSSBase.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPersistentStorage+Push.h>
#import <MSSPush/MSSPushDebug.h>

@interface AppDelegate ()

@property (nonatomic) BOOL registered;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[Settings defaults]];
    
    [self initializeSDK];
    return YES;
}

- (void)initializeSDK
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    static BOOL usePlist = YES;
    MSSParameters *parameters;
    if (usePlist) {
        parameters = [MSSParameters defaultParameters];
        
    } else {
        //MSSParameters configured in code
        parameters = [Settings registrationParameters];
        NSString *message = [NSString stringWithFormat:@"Initializing library with parameters: variantUUID: \"%@\" variantSecret: \"%@\" deviceAlias: \"%@\".",
                             parameters.variantUUID,
                             parameters.variantSecret,
                             parameters.pushDeviceAlias];
        MSSPushLog(message);
    }
    
    [MSSPush setRegistrationParameters:parameters];

    [MSSPush setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        MSSPushLog(@"Application received callback \"registrationSucceeded\".");
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        MSSPushLog(@"Application received callback \"registrationFailedWithError:\". Error: \"%@\"", error.localizedDescription);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    MSSPushLog(@"Received message: %@", userInfo[@"aps"][@"alert"]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    MSSPushLog(@"FetchCompletionHandler Received message:");
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
