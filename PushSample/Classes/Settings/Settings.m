//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "Settings.h"
#import <MSSPush/MSSParameters.h>

static NSString *const BACK_END_REQUEST_URL = @"http://cfms-push-service-dev.one.pepsi.cf-app.com";

static NSString *const DEFAULT_VARIANT_UUID   = @"e72f8cc0-0625-4e8f-8926-40f274c87838";
static NSString *const DEFAULT_VARIANT_SECRET = @"e468d440-b912-47ec-8a0c-2502be9d596c";
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
    [params setProductionPushVariantUUID:[Settings variantUUID]];
    [params setProductionPushVariantSecret:[Settings variantSecret]];
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
