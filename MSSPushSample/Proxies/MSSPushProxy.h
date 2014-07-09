//
//  MSSPushProxy.h
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RegistrationSettings;
@class LogItem;

@protocol MSSPushProxyLogClient <NSObject>

- (void)logDidRecordItem:(LogItem *)logItem;

@end

@interface MSSPushProxy : NSObject

+ (instancetype)defaultProxy;
+ (NSOperationQueue *)networkQueue;

- (void)updateSettings:(RegistrationSettings *)settings;
- (void)clearPushLog;
- (NSArray *)currentPushLog;
- (void)addLogItem:(LogItem *)logItem;

- (void)addLogClient:(id<MSSPushProxyLogClient>)logClient;
- (void)removeLogClient:(id<MSSPushProxyLogClient>)logClient;

- (NSString *)deviceIdentifier;

@end
