//
//  GeofenceOverlay.m
//  PushSample
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
