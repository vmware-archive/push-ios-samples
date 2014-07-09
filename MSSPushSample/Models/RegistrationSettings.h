//
//  RegistrationSettings.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegistrationSettings : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *url;

+ (RegistrationSettings *)defaultSettings;
+ (RegistrationSettings *)loadRegistrationSettings;

- (void)saveRegistrationSettings;

@end
