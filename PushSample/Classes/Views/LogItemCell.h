//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LogItem;

@interface LogItemCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *labelMessage;
@property (nonatomic) IBOutlet UILabel *labelTimestamp;
@property (nonatomic) LogItem *logItem;

- (void) setLogItem:(LogItem *)item containerSize:(CGSize)containerSize;
- (CGRect) frameForLabelWithText:(NSString*)text containerSize:(CGSize)containerSize;

+ (CGFloat) heightForCellWithText:(NSString*)text containerSize:(CGSize)containerSize;
+ (CGFloat) heightForLabelWithText:(NSString*)text containerSize:(CGSize)containerSize;

@end
