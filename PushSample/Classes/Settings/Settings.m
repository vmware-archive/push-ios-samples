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

#import "Settings.h"

//
// IMPORTANT
//
// These settings are used by the Push Sample app for making push message requests to the
// Pivotal CF Mobile Services Push server.  Sending push message requestst is simply a
// demonstration feature of this sample application and is NOT a feature of the
// Pivotal CF Mobile Service Push Client SDK.
//
// These settings are NOT used when registering with the server.  Please see the file
// "PCFParameters.plist" to change the registration parameters.  These settings are only
// used when the Sample App tries to send messages to itself.
//

NSString *const APP_UUID = @"23a83339-b40b-453a-92da-92414321a7ab";
NSString *const API_KEY = @"753a05ad-d88e-43b4-8819-7497d644c917";
NSString *const BACK_END_PUSH_MESSAGE_API = @"http://push-api.kitkat.cf-app.com/v1/push";

@implementation Settings

+ (void) setTag:(NSString*)tag
{
    [[NSUserDefaults standardUserDefaults] setObject:tag forKey:@"TAG"];
}

+ (NSString*) tag
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"TAG"];
}

+ (void) setCustomUserId:(NSString*)customUserId
{
    [[NSUserDefaults standardUserDefaults] setObject:customUserId forKey:@"CUSTOM_USER_ID"];
}

+ (NSString*) customUserId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOM_USER_ID"];
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
