//
//  MSSPushProxy.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "MSSPushProxy.h"
#import "MSSPushDebug.h"
#import "MSSPersistentStorage+Push.h"
#import "RegistrationSettings.h"
#import "LogItem.h"

@interface MSSPushProxy ()

@property (nonatomic, strong) NSMutableArray *logItems;
@property (nonatomic, strong) NSMutableArray *logClients;

@end

//A proxy object for interacting with whatever object(s) actually implement(s) the SDK.
@implementation MSSPushProxy

static MSSPushProxy *defaultProxy;
+ (instancetype)defaultProxy {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultProxy = [MSSPushProxy new];
    });
    return defaultProxy;
}

static NSOperationQueue *networkQueue;
+ (NSOperationQueue *)networkQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkQueue = [NSOperationQueue new];
    });
    return networkQueue;
}

- (instancetype)init {
    if ( (self = [super init]) ) {
        self.logItems = [NSMutableArray new];
        self.logClients = [NSMutableArray new];
        [MSSPushDebug setLogListener:^(NSString *message, NSDate *timestamp) {
            [[MSSPushProxy defaultProxy] addLogItem:[[LogItem alloc] initWithMessage:message timestamp:timestamp]];
        }];
    }
    return self;
}

- (id)MSSPushImplementation {
    return [UIApplication sharedApplication].delegate;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id targetObject = [self MSSPushImplementation];
    if ([targetObject respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:targetObject];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (void)updateSettings:(RegistrationSettings *)settings {
    [settings saveRegistrationSettings];
    NSLog(@"settings:\n %@", settings);
}

- (NSArray *)currentPushLog {
    return [self.logItems copy];
}

- (void)clearPushLog {
    self.logItems = [NSMutableArray new];
}

- (void)addLogItem:(LogItem *)logItem {
    [self.logItems addObject:logItem];
    for (__weak id<MSSPushProxyLogClient> client in self.logClients) {
        if ([client conformsToProtocol:@protocol(MSSPushProxyLogClient)]) {
            if ([NSThread currentThread] != [NSThread mainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [client logDidRecordItem:logItem];
                });
            } else {
                [client logDidRecordItem:logItem];
            }
        }
     }
}

- (void)addLogClient:(id<MSSPushProxyLogClient>)logClient {
    [self.logClients addObject:logClient];
}

- (void)removeLogClient:(id<MSSPushProxyLogClient>)logClient {
    [self.logClients removeObject:logClient];
}

- (NSString *)deviceIdentifier {
    return [MSSPersistentStorage serverDeviceID];
}

@end
