//
//  TriggerNotificationOperation.h
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TriggerNotificationOperation : NSOperation

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@end
