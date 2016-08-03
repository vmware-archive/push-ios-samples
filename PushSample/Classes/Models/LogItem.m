//
//  Copyright (C) 2014 - 2016 Pivotal Software, Inc. All rights reserved. 
//  
//  This program and the accompanying materials are made available under 
//  the terms of the under the Apache License, Version 2.0 (the "License”); 
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "LogItem.h"

NSString *const LOG_ITEM_CELL = @"LogItemCell";

static int currentBaseRowColour = 0;
static int numItems = 0;

@interface LogItem ()

@property (nonatomic) NSString *_formattedTimestamp;

@end

@implementation LogItem

- (instancetype) initWithMessage:(NSString*)message timestamp:(NSDate*)timestamp
{
    self = [super init];
    if (self) {
        self.message = message;
        self.timestamp = timestamp;
        self.colour = [self getColour];
    }
    return self;
}

- (UIColor*) getColour
{
    static NSArray *darkBaseRowColours = nil;
    if (darkBaseRowColours == nil) {
        darkBaseRowColours = @[[UIColor colorWithRed:0.85f green:0.75f blue:0.75f alpha:1.0f],
                           [UIColor colorWithRed:0.75f green:0.85f blue:0.75f alpha:1.0f],
                           [UIColor colorWithRed:0.75f green:0.75f blue:0.85f alpha:1.0f]];
    }
    
    static NSArray *lightBaseRowColours = nil;
    if (lightBaseRowColours == nil) {
        lightBaseRowColours = @[[UIColor colorWithRed:0.95f green:0.8f blue:0.8f alpha:1.0f],
                               [UIColor colorWithRed:0.8f green:0.95f blue:0.8f alpha:1.0f],
                               [UIColor colorWithRed:0.8f green:0.8f blue:0.95f alpha:1.0f]];
    }

    numItems += 1;
    if (numItems % 2) {
        return darkBaseRowColours[currentBaseRowColour % darkBaseRowColours.count];
    } else {
        return lightBaseRowColours[currentBaseRowColour % lightBaseRowColours.count];
    }
}

- (NSString*) formattedTimestamp
{
    if (self._formattedTimestamp != nil) {
        return self._formattedTimestamp;
    }
    
    if (self.timestamp == nil) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [LogItem getDateFormatter];
    self._formattedTimestamp = [dateFormatter stringFromDate:self.timestamp];
    return self._formattedTimestamp;
}

+ (NSDateFormatter*) getDateFormatter
{
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

+ (void) updateBaseColour
{
    currentBaseRowColour += 1;
}

@end
