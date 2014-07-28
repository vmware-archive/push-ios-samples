//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

@property (nonatomic) IBOutlet UITextField* releaseUuidTextField;
@property (nonatomic) IBOutlet UITextField* releaseSecretTextField;
@property (nonatomic) IBOutlet UITextField* deviceAliasTextField;
@property (nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction) clearRegistrationPressed:(id)sender;
- (IBAction) resetToDefaults:(id)sender;

@end
