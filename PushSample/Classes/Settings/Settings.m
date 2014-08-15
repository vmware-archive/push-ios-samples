//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "Settings.h"
#import <MSSPush/MSSParameters.h>

static NSString *const BACK_END_REQUEST_URL = @"http://cfms-push-service-dev.main.vchs.cfms-apps.com";

static NSString *const DEFAULT_VARIANT_UUID   = @"ada50420-640d-43a3-8bb0-6fd0e0b212ba";
static NSString *const DEFAULT_VARIANT_SECRET = @"603ebaf5-3ef6-4465-a119-5f0b80cc7443";
static NSString *const DEFAULT_DEVICE_ALIAS   = @"Default Device Alias";

static NSString *const KEY_VARIANT_UUID    = @"KEY_VARIANT_UUID";
static NSString *const KEY_VARIANT_SECRET  = @"KEY_VARIANT_SECRET";
static NSString *const KEY_DEVICE_ALIAS    = @"KEY_DEVICE_ALIAS";

@implementation Settings

+ (NSString *)variantUUID {
  return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_VARIANT_UUID];
}

+ (void)setVariantUUID:(NSString *)variantUUID
{
    [[NSUserDefaults standardUserDefaults] setObject:variantUUID forKey:KEY_VARIANT_UUID];
}

+ (NSString *)variantSecret
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_VARIANT_SECRET];
}

+ (void)setVariantSecret:(NSString *)variantSecret
{
    [[NSUserDefaults standardUserDefaults] setObject:variantSecret forKey:KEY_VARIANT_SECRET];
}

+ (NSString *)deviceAlias
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_DEVICE_ALIAS];
}

+ (void)setDeviceAlias:(NSString *)deviceAlias
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceAlias forKey:KEY_DEVICE_ALIAS];
}

+ (void)resetToDefaults
{
    [self setVariantUUID:DEFAULT_VARIANT_UUID];
    [self setVariantSecret:DEFAULT_VARIANT_SECRET];
    [self setDeviceAlias:DEFAULT_DEVICE_ALIAS];
}

+ (MSSParameters *)registrationParameters
{
    MSSParameters *params = [MSSParameters parameters];
    [params setPushAPIURL:BACK_END_REQUEST_URL];
    [params setDevelopmentPushVariantUUID:[Settings variantUUID]];
    [params setDevelopmentPushVariantSecret:[Settings variantSecret]];
    [params setPushDeviceAlias:[Settings deviceAlias]];
    return params;
}

+ (NSDictionary *)defaults
{
	NSDictionary *defaults = @{
		KEY_VARIANT_UUID   : DEFAULT_VARIANT_UUID,
		KEY_VARIANT_SECRET : DEFAULT_VARIANT_SECRET,
		KEY_DEVICE_ALIAS   : DEFAULT_DEVICE_ALIAS,
	};
	return defaults;
}

@end
