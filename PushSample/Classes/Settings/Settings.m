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
// "MSSParameters.plist" to change the registration parameters.

NSString *const ENVIRONMENT_UUID = @"a0983f9f-eeb2-4073-bcbe-011c0bad436f";
NSString *const ENVIRONMENT_SECRET = @"56d0ecee-c83d-4c11-b26c-4ff4a9b6da40";
NSString *const BACK_END_PUSH_MESSAGE_API = @"http://cfms-push-service-dev.one.pepsi.cf-app.com/v1/push";
