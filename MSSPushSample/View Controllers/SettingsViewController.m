//
//  SettingsViewController.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "SettingsViewController.h"
#import "RegistrationSettings.h"
#import "MSSPushProxy.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.view setVersion:[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    self.settings = [RegistrationSettings loadRegistrationSettings];
    [self updateViewFromSettings];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGSize finalKeyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, finalKeyboardSize.height, 0.0);
    [self.view adjustViewForUIEdgeInsets:contentInsets];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.view adjustViewForUIEdgeInsets:UIEdgeInsetsZero];
}

- (void)updateViewFromSettings {
    self.view.uuid = self.settings.uuid;
    self.view.alias = self.settings.alias;
    self.view.secret = self.settings.secret;
}

- (IBAction)clearRegistrationSettings:(UIButton *)sender {
    self.settings = [RegistrationSettings new];
    [self updateViewFromSettings];
}
 

- (IBAction)resetRegistrationSettings:(UIButton *)sender {
    self.settings = [RegistrationSettings defaultSettings];
    [self updateViewFromSettings];
}

- (IBAction)updateSettings:(UITextField *)sender {
    self.settings.uuid = self.view.uuid;
    self.settings.secret = self.view.secret;
    self.settings.alias = self.view.alias;
    
    [[MSSPushProxy defaultProxy] updateSettings:self.settings];
}

@end
