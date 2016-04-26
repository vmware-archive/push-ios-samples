//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const APP_UUID;
OBJC_EXTERN NSString *const API_KEY;
OBJC_EXTERN NSString *const BACK_END_PUSH_MESSAGE_API;

@interface Settings : NSObject

+ (void) setTag:(NSString*)tag;
+ (NSString*) tag;
+ (void) setCustomUserId:(NSString*)customUserId;
+ (NSString*) customUserId;
+ (void) setAreGeofencesEnabled:(BOOL)areGeofencesEnabled;
+ (BOOL) areGeofencesEnabled;

@end