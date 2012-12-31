//
//  VMDMapViewController.h
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDTabBarController.h"
#import "VMDAppDelegate.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface VMDMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) VMDTabBarController *vmdTBC;
@property (strong, nonatomic) VMDAppDelegate *appDelegate;

@end
