//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "Settings.h"

// These settings are used by the Push Sample app for making push message requests to the
// Pivotal CF Mobile Services Push server.  Sending push message requestst is simply a
// demonstration feature of this sample application and is NOT a feature of the
// Pivotal CF Mobile Service Push Client SDK.
//
// These settings are NOT used when registering with the server.  Please see the file
// "PCFParameters.plist" to change the registration parameters.

@implementation Settings

+ (void) setTag:(NSString*)tag
{
    [[NSUserDefaults standardUserDefaults] setObject:tag forKey:@"TAG"];
}

+ (NSString*) tag
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"TAG"];
}

+ (void) setAreGeofencesEnabled:(BOOL)areGeofencesEnabled
{
    [[NSUserDefaults standardUserDefaults] setObject:@(areGeofencesEnabled) forKey:@"ARE_GEOFENCES_ENABLED"];
}

+ (BOOL) areGeofencesEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ARE_GEOFENCES_ENABLED"] boolValue];
}

@end

NSString *const APP_UUID = @"396913a2-01fc-4c8c-858c-d2e8857f2c6d";
NSString *const API_KEY = @"38375788-efbc-4091-8e23-477f90e8cf76";
NSString *const BACK_END_PUSH_MESSAGE_API = @"http://push-api.hellfire.cf-app.com/v1/push";
