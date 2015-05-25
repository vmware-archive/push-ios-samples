//
//  GeofenceOverlay.h
//  PushSample
//
//  Created by DX173-XL on 2015-05-25.
//  Copyright (c) 2015 DX123-XL. All rights reserved.
//

#import <MapKit/MapKit.h>

extern BOOL isExpired(NSDate *date);

@interface GeofenceOverlay : MKCircle

@property NSDate *expiry;

- (MKCircleRenderer*) circleRenderer;

@end
