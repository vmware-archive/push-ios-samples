//
//  SettingsViewController.h
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsView.h"

@class RegistrationSettings;

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) SettingsView *view;
@property (nonatomic, strong) RegistrationSettings *settings;

@end
