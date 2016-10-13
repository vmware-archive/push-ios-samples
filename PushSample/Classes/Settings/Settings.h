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
