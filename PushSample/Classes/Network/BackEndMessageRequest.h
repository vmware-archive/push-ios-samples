//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackEndMessageRequest : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) NSString *appUuid;
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *messageBody;
@property (nonatomic) NSString *category;
@property (nonatomic) NSArray *targetDevices;
@property (nonatomic) NSSet *tags;

- (void) sendMessage;

@end
