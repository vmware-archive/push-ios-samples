//
//  GeofenceOverlay.m
//  PushSample
//
//  Created by DX173-XL on 2015-05-25.
//  Copyright (c) 2015 DX123-XL. All rights reserved.
//

#import "GeofenceOverlay.h"

BOOL isExpired(NSDate *date)
{
    NSDate *now = [NSDate date];
    return ([date laterDate:now] == now);
}

@implementation GeofenceOverlay

- (MKCircleRenderer*) circleRenderer
{
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:self];
    circleRenderer.lineWidth = 1.0;
    
    if (isExpired(self.expiry)) {
        circleRenderer.strokeColor = [UIColor redColor];
        circleRenderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    } else {
        circleRenderer.strokeColor = [UIColor blueColor];
        circleRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
    }

    return circleRenderer;
}

@end
