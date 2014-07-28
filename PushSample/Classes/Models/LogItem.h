//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const LOG_ITEM_CELL;

@interface LogItem : NSObject

@property (nonatomic) NSString *message;
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) UIColor *colour;

- (instancetype) initWithMessage:(NSString*)message timestamp:(NSDate*)timestamp;
- (NSString*) formattedTimestamp;

+ (void) updateBaseColour;
+ (NSDateFormatter*) getDateFormatter;

@end
