//
//  SettingsView.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "SettingsView.h"

@interface SettingsView ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UITextField *uuidTextField;
@property (nonatomic, weak) IBOutlet UITextField *secretTextField;
@property (nonatomic, weak) IBOutlet UITextField *aliasTextField;

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;

@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@end

@implementation SettingsView

- (void)adjustViewForUIEdgeInsets:(UIEdgeInsets)edgeInsets {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentInset = edgeInsets;
        self.scrollView.scrollIndicatorInsets = edgeInsets;
    }];
    
    if (&edgeInsets == &UIEdgeInsetsZero) {
        return;
    }
    
    CGRect newViewFrame = UIEdgeInsetsInsetRect(self.scrollView.frame, edgeInsets);
    for (UITextField *textField in self.textFields) {
        if (textField.isFirstResponder && !CGRectContainsPoint(newViewFrame, textField.frame.origin)) {
            [self.scrollView scrollRectToVisible:textField.frame animated:YES];
        }
    }

}

- (void)setVersion:(NSString *)version {
    self.versionLabel.text = version;
}

- (NSString *)version {
    return self.versionLabel.text;
}

- (void)setAlias:(NSString *)alias {
    self.aliasTextField.text = alias;
}

- (NSString *)alias {
    return self.aliasTextField.text;
}

- (void)setUuid:(NSString *)uuid {
    self.uuidTextField.text = uuid;
}

- (NSString *)uuid {
    return self.uuidTextField.text;
}

- (void)setSecret:(NSString *)secret {
    self.secretTextField.text = secret;
}

- (NSString *)secret {
    return self.secretTextField.text;
}

@end
