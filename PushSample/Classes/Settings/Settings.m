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

NSString *const APP_UUID = @"4db64303-faa9-46d0-b405-853eb2680213";
NSString *const API_KEY = @"c267222c-643d-46e6-a120-b7dab2955da3";
NSString *const BACK_END_PUSH_MESSAGE_API = @"http://push-notifications.gulch.cf-app.com/v1/push";
