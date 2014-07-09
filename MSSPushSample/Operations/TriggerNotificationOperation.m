//
//  TriggerNotificationOperation.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "TriggerNotificationOperation.h"
#import "MSSPushProxy.h"
#import "MSSPushDebug.h"
#import "RegistrationSettings.h"

@implementation TriggerNotificationOperation

- (void)main {
    NSMutableURLRequest *pushNotificationRequest = [NSMutableURLRequest new];
    pushNotificationRequest.HTTPMethod = @"POST";
    pushNotificationRequest.URL = [NSURL URLWithString:@"http://push-notifications.sherry.wine.cf-app.com"];
    pushNotificationRequest.timeoutInterval = 60;
    pushNotificationRequest.HTTPBody = [self notificationPayload];
    
    NSHTTPURLResponse *pushNotificationResponse;
    NSError *error;
    [NSURLConnection sendSynchronousRequest:pushNotificationRequest returningResponse:&pushNotificationResponse error:&error];
    if (error) {
        MSSPushLog(@"Got error when attempting to connect to push server");
        return;
    }
    
    if (pushNotificationResponse.statusCode > 299 || pushNotificationResponse.statusCode < 200) {
        MSSPushLog(@"Got HTTP failure status code when trying to push message via back-end server: %d", pushNotificationResponse.statusCode);
    }
}

- (NSData *)notificationPayload {
    RegistrationSettings *registrationSettings = [RegistrationSettings loadRegistrationSettings];
    NSString *deviceIdentifier = [[MSSPushProxy defaultProxy] deviceIdentifier];
    if (!deviceIdentifier) {
        MSSPushLog(@"Could not get a device identifier -- was the registration successful?");
        return nil;
    }
    NSDictionary *payloadDictionary = @{
        @"app_uuid" : registrationSettings.uuid,
        @"app_secret_key" : registrationSettings.secret,
        @"message":@{ @"title":self.title, @"body":self.message },
        @"target":@{ @"platforms":@[@"ios"], @"devices": @[deviceIdentifier] },
    };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadDictionary options:0 error:&error];
    if (!error) {
        return jsonData;
    }
    MSSPushCriticalLog(@"Error upon serializing object to JSON: %@", error);
    return nil;
}

@end