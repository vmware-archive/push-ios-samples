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

NSString *const APP_UUID = @"fddb5fd2-85af-45a6-b828-9efaa66f019c";
NSString *const API_KEY = @"25eb569a-750a-4c3f-9e7b-75be9097dd2b";
NSString *const BACK_END_PUSH_MESSAGE_API = @"http://them-pirates.cfapps.io/v1/push";
