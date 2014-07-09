//
//  RegistrationSettings.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "RegistrationSettings.h"



//<string name="pref_default_gcm_sender_id">641043317726</string>
//<string name="pref_default_back_end_environment_uuid">db2e2680-9540-4364-b878-f19c46a0bf3d</string>
//<string name="pref_default_back_end_environment_key">c22dad22-b07e-4c08-9d9f-46617d01c6e2</string>

static NSString * const defaultUUID = @"a183a4ab-83b1-45ef-ba92-3727454dbc4b";
static NSString * const defaultSecret = @"5c9b1b8a-b2fe-4c66-a01b-37797af485fd";
static NSString * const defaultAlias = @"Default Device Alias";
static NSString * const defaultPushURL = @"http://push-notifications.sherry.wine.cf-app.com";
static NSString * const userDefaultsKey = @"MMSPushRegistrationSettingsKey";

@implementation RegistrationSettings

+ (RegistrationSettings *)defaultSettings {
    RegistrationSettings *defaultSettings = [RegistrationSettings new];
    defaultSettings.secret = defaultSecret;
    defaultSettings.alias = defaultAlias;
    defaultSettings.uuid = defaultUUID;
    defaultSettings.url = defaultPushURL;
    return defaultSettings;
}

- (NSString *)description {
    NSString *description = [NSString new];
    description = [[description stringByAppendingString:@"UUID: "] stringByAppendingString:self.uuid];
    description = [[description stringByAppendingString:@"\nSecret: "] stringByAppendingString:self.secret];
    description = [[description stringByAppendingString:@"\nAlias: "] stringByAppendingString:self.alias];
    description = [[description stringByAppendingString:@"\nURL: "] stringByAppendingString:self.url];
    return description;
}

+ (RegistrationSettings *)loadRegistrationSettings {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray *settingsArray = [[NSUserDefaults standardUserDefaults] valueForKey:userDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    RegistrationSettings *settings;
    if (settingsArray && settingsArray.count == 3) {
        settings = [RegistrationSettings new];
        settings.uuid = settingsArray[0];
        settings.secret = settingsArray[1];
        settings.alias = settingsArray[2];
    } else {
        settings = [RegistrationSettings defaultSettings];
    }
    return settings;
}

- (void)saveRegistrationSettings {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray *settingsArray = @[self.uuid, self.secret, self.alias];
    [[NSUserDefaults standardUserDefaults] setObject:settingsArray forKey:userDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
