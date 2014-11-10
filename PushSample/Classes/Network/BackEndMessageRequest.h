//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackEndMessageRequest : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) NSString *environmentUuid;
@property (nonatomic) NSString *environmentSecret;
@property (nonatomic) NSString *messageBody;
@property (nonatomic) NSString *category;
@property (nonatomic) NSArray *targetDevices;

- (void) sendMessage;

@end
