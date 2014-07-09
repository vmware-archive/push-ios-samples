//
//  LogItem.h
//  MSSPushSDK
//
//  Created by Rob Szumlakowski on 2013-12-17.
//  Copyright (c) 2013 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogItem : NSObject

@property (nonatomic) NSString *message;
@property (nonatomic) NSDate *timestamp;

- (instancetype) initWithMessage:(NSString*)message timestamp:(NSDate*)timestamp;

@end
