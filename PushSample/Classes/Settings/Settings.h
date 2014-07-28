//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSSParameters;

@interface Settings : NSObject

+ (NSString *)variantUUID;
+ (void)setVariantUUID:(NSString *)variantUUID;

+ (NSString *)releaseSecret;
+ (void)setReleaseSecret:(NSString *)releaseSecret;

+ (NSString *)deviceAlias;
+ (void)setDeviceAlias:(NSString *)deviceAlias;

+ (void)resetToDefaults;

+ (MSSParameters *)registrationParameters;
+ (NSDictionary *)defaults;

@end
