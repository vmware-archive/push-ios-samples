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

NSString *const ENVIRONMENT_UUID = @"3f19f4a4-67b4-45a9-aa19-e73b9fc8bc68";
NSString *const ENVIRONMENT_SECRET = @"92d293de-ebf7-4426-8546-b98c8ebb4333";
NSString *const BACK_END_PUSH_MESSAGE_API = @"http://push-notifications.demo.vchs.cfms-apps.com/v1/push";
