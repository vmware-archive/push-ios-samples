//
//  LogItemCollectionViewController.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "LogItemCollectionViewController.h"
#import "LogItemCollectionViewCell.h"
#import "LogItem.h"
#import "MSSPushProxy.h"
#import "TriggerNotificationOperation.h"

@interface LogItemCollectionViewController () <MSSPushProxyLogClient>

@property (nonatomic, strong) NSArray *logItems;

@end

@implementation LogItemCollectionViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.logItems = [[MSSPushProxy defaultProxy] currentPushLog];
    [[MSSPushProxy defaultProxy] addLogClient:self];
}

- (IBAction)unwindModalToLogItemCollection:(UIStoryboardSegue *)sender {
    return;
}

#pragma mark <UICollectionViewDataSource>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.logItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LogItemCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    LogItem *logItem = [self logItemForIndexPath:indexPath];
    
    [cell setMessage:logItem.message];
    [cell setTimestamp:logItem.timestamp];
    
    return cell;
}

- (IBAction)sendPushNotificationRequest:(id)sender {
    TriggerNotificationOperation *operation = [TriggerNotificationOperation new];
    operation.title = @"push notification";
    operation.message = @"this is a push notification";
    [[MSSPushProxy networkQueue] addOperation:operation];
}

- (IBAction)clearLog:(id)sender {
    [[MSSPushProxy defaultProxy] clearPushLog];
    self.logItems = [[MSSPushProxy defaultProxy] currentPushLog];
    [self.collectionView reloadData];
}

- (IBAction)copyLog:(id)sender
{
    NSMutableString *logContents = [NSMutableString new];
    for (LogItem *logItem in self.logItems) {
        [logContents appendFormat:@"%@\t%@\n", logItem.timestamp, logItem.message];
    }
    [[UIPasteboard generalPasteboard] setString:logContents];
}

- (LogItem *)logItemForIndexPath:(NSIndexPath *)indexPath {
    return self.logItems[indexPath.item];
}

- (void)logDidRecordItem:(LogItem *)logItem {
    NSInteger previousItemCount = self.logItems.count;
    self.logItems = [[MSSPushProxy defaultProxy] currentPushLog];
    NSInteger newItemCount = self.logItems.count - previousItemCount;
    NSMutableArray *insertedIndexPaths = [NSMutableArray new];
    for (NSInteger newItemIndex = 0; newItemIndex < newItemCount; newItemIndex++) {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:(previousItemCount + newItemIndex) inSection:0]];
    }
    
    [self.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
}

@end
