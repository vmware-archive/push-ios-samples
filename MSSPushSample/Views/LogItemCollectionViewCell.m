//
//  LogItemCollectionViewCell.m
//  MSSPushSample
//
//  Created by Adrian Kemp on 2014-07-02.
//  Copyright (c) 2014 DX123-XL. All rights reserved.
//

#import "LogItemCollectionViewCell.h"

@interface LogItemCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *logMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;

@end

NSString * const reuseIdentifier = @"LogItemCell";

@implementation LogItemCollectionViewCell

+ (NSString *)reuseIdentifier {
    return reuseIdentifier;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.timestampLabel.text = nil;
    self.logMessageLabel.text = nil;
    
    return;
}

- (void)setTimestamp:(NSDate *)timestamp {
    self.timestampLabel.text = [NSString stringWithFormat:@"%@", timestamp];
}

- (void)setMessage:(NSString *)message {
    self.logMessageLabel.text = message;
}

@end
