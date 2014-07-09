//
//  LogItem.m
//  MSSPushSDK
//
//  Created by Rob Szumlakowski on 2013-12-17.
//  Copyright (c) 2013 Pivotal. All rights reserved.
//

#import "LogItem.h"

@interface LogItem ()

@end

@implementation LogItem

- (instancetype) initWithMessage:(NSString*)message timestamp:(NSDate*)timestamp {
    self = [super init];
    if (self) {
        self.message = message;
        self.timestamp = timestamp;
    }
    return self;
}

@end
