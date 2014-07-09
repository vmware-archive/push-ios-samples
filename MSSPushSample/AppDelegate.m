//
//  AppDelegate.m
//  DemoApp
//
//  Created by Rob Szumlakowski on 2013-12-13.
//  Copyright (c) 2013 Pivotal. All rights reserved.
//

#import "AppDelegate.h"
#import "RegistrationSettings.h"
#import "MSSPushProxy.h"
#import "MSSPushSDK.h"
#import "MSSParameters.h"

@interface AppDelegate ()

@property (nonatomic) BOOL registered;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MSSPushProxy defaultProxy];
    RegistrationSettings *settings = [RegistrationSettings defaultSettings];
    
    MSSParameters *pushParameters = [MSSParameters parameters];
    [pushParameters setPushAPIURL:settings.url];
    [pushParameters setPushDeviceAlias:settings.alias];
    [pushParameters setProductionPushVariantUUID:settings.uuid];
    [pushParameters setProductionPushReleaseSecret:settings.secret];
    
    [MSSPushSDK setRegistrationParameters:pushParameters];
    

    return YES;
}

@end
