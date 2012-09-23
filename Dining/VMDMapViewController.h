//
//  VMDMapViewController.h
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VMDMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end
