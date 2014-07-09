//
//  SettingsView.h
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UIView

@property (nonatomic, weak) NSString *version;

@property (nonatomic, weak) NSString *uuid;
@property (nonatomic, weak) NSString *alias;
@property (nonatomic, weak) NSString *secret;

- (void)adjustViewForUIEdgeInsets:(UIEdgeInsets)edgeInsets;

@end
