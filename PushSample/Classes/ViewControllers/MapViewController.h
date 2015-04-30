//
//  MapViewController.h
//  PushSample
//
//  Created by DX173-XL on 2015-04-30.
//  Copyright (c) 2015 DX123-XL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;

@end
