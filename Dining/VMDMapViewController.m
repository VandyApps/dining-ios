//
//  VMDMapViewController.m
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDMapViewController.h"
#import "VMDAnnotation.h"
#import "DLocation.h"
#import "VMDLocationDetailVC.h"

#define METERS_PER_MILE 1609.344

@interface VMDMapViewController ()

@end

@implementation VMDMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    
    // Grab the app delegate for use of the sliding view controller
    self.appDelegate = (VMDAppDelegate *)[[UIApplication sharedApplication] delegate];

}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
//    CLLocationManager *locManager = [CLLocationManager new];
//    locManager.delegate = self;
//    [locManager startUpdatingLocation];

    // Configure mapView to track user location
    [self.mapView setShowsUserLocation:YES];
    
    // Coordinates of Vanderbilt University Campus
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 36.143566;
    zoomLocation.longitude= -86.805906;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.8*METERS_PER_MILE, 0.8*METERS_PER_MILE);
    
    // 3
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    
    // 4
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    if ([self.mapView.annotations count] == 0) {
        int i = 0;
        for (DLocation *location in self.vmdTBC.mapItems) {
            VMDAnnotation *annotation = [[VMDAnnotation alloc] initWithTitle:location.name subtitle:location.type andCoordinate:CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue])];
            annotation.idNum = [NSNumber numberWithInt:i];
            i++;
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - IBAction methods

- (IBAction)trackPressed:(UIBarButtonItem *)sender {
    
    if (self.mapView.userTrackingMode == MKUserTrackingModeNone) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    else if (self.mapView.userTrackingMode == MKUserTrackingModeFollow) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    }
    else if (self.mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading) [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

#pragma mark - MKMapViewDelegate methods 

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"VMDLocation";
    if ([annotation isKindOfClass:[VMDAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = YES;
            
            //instatiate a detail-disclosure button and set it to appear on right side of annotation
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //annoView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            annotationView.rightCalloutAccessoryView = infoButton;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"Detail" sender:[(VMDAnnotation *)view.annotation idNum]];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (manager.location) {
        [self.mapView setRegion:MKCoordinateRegionMake(manager.location.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    if (manager.location) {
        [self.mapView setRegion:MKCoordinateRegionMake(manager.location.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
    }
}

#pragma mark - Storyboard methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[self.appDelegate viewController] setLocked:YES];
    
    // Get the destination view controller from the segue
    VMDLocationDetailVC *destination = [segue destinationViewController];
    
    DLocation *loc = [self.vmdTBC.mapItems objectAtIndex:[sender integerValue]];
    
    // Set the title
    destination.title = [loc name];
    
    // Set the destination's location property
    destination.location = loc;
}



@end
