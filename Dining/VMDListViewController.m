//
//  VMDListViewController.m
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "VMDListViewController.h"
#import "VMDLocationDetailVC.h"
#import "SAViewManipulator.h"
#import "VMDSectionHeaderView.h"

#import "UIColor+i7HexColor.h"
#import "UIView+Frame.h"
#import "UIBarButtonItem+Custom.h"
#import "UIImage+Color.h"
#import "CLLocation+AFExtensions.h"

#define METERS_PER_MILE 1609.344
#define kSortIdentifierAlphabetical @"SORT_ID_ALPHABETICAL"
#define kSortIdentifierNear @"SORT_ID_NEAR"
#define kSortIdentifierCategory @"SORT_ID_CATEGORY"


@interface VMDListViewController ()


@end

@implementation VMDListViewController
{
	PullToRefreshView *pull;
}

@synthesize tableView = _tableView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataSource = _dataSource;

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.sortIdentifier = kSortIdentifierNear;
    
    // Grab the app delegate for use of the sliding view controller
    self.appDelegate = (VMDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Fetch the data from the Core Data context
    [self fetchDataFromContext];
    
    // Configure the data
    [self configureDataWithSortIdentifier:kSortIdentifierNear];
    
    // Customize the UI
    [self customizeUI];

    self.locManager = [CLLocationManager new];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.locManager startUpdatingLocation];
    [self.locManager startUpdatingHeading];
    
    self.motionManager = [CMMotionManager new];
//    [self.motionManager startAccelerometerUpdates];
//    [self.motionManager startGyroUpdates];
	[self.motionManager startDeviceMotionUpdates];
    
	pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
	[pull setDelegate:self];
	[self.tableView addSubview:pull];
    [self.tableView registerClass:[VMDListCell class] forCellReuseIdentifier:@"VMDiningCell"];
    
//    self.directingLocation = [[self.dataSource objectAtIndex:1] objectAtIndex:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self.appDelegate viewController] setLocked:NO];
    
    VMDListCell *cell = [[VMDListCell alloc] init];
    UIGraphicsBeginImageContextWithOptions(cell.accessoryView.size, YES, [UIScreen mainScreen].scale);
    [cell.accessoryView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory ,@"Test.png"];
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *docsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:docsDirectory error:&error]);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VMDining_NavBar"]]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[self.navigationController.navigationBar subviews] lastObject] removeFromSuperview];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self refreshData:nil];
    [pull performSelector:@selector(finishedLoading) withObject:nil afterDelay:1.5];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setFeaturedCellContainerView:nil];
    [self setFeaturedCellButton:nil];
    [self setNearestDistance:nil];
    [self setDirectionImageView:nil];
    [self setNearestNameLabel:nil];
    [self setNearestCategoryLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - Core Data

// Grabs the data from Core Data
- (void)fetchDataFromContext {
    
    // New fetch request object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Derive an entitity description for DLocation from the context
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DLocation" inManagedObjectContext:self.managedObjectContext];
    
    // Set the fetch request's entity property to be that entity
    [fetchRequest setEntity:entity];
    
    // Fetch the data from the context, set it to the dataSource array
    NSError *error;
    self.oldDataSource = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *mapItems = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    for (DLocation *location in self.oldDataSource) {
        if ([location isKindOfClass:[DLocation class]]) {
            [mapItems addObject:location];
        }
    }
    self.vmdTBC.mapItems = [mapItems copy];
}

// Configures the data in the tableView based on the sortIdentifier
- (void)configureDataWithSortIdentifier:(NSString *)sortIdentifier {
    
    NSArray *sortedData;
    NSMutableArray *sectionedDataSource = [NSMutableArray array];
    NSMutableSet *hash = [NSMutableSet set];
    
    // Alphabetical (and Category)
    if ([sortIdentifier isEqualToString:kSortIdentifierAlphabetical] ||[sortIdentifier isEqualToString:kSortIdentifierCategory]) {
        sortedData = [self sortDataAlphabetical:[self.oldDataSource mutableCopy]];
    }
    
    // Near
    else if ([sortIdentifier isEqualToString:kSortIdentifierNear]) {
        
        // Sort data by nearness, use CoreLocation
        sortedData = [self sortDataNear:[self.oldDataSource mutableCopy]];
        
        for (int i = 0; i < 7; ++i) {
            [sectionedDataSource addObject:[NSArray array]];
        }
    }
    
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    
    for (DLocation *location in sortedData) {
        if (![hash containsObject:location.name]) {
            [hash addObject:location.name];
            
            // If alphabetical sort
            if ([sortIdentifier isEqualToString:kSortIdentifierAlphabetical]) {
                
                bool found = false;
                for (int i = 0; i < sectionedDataSource.count; i++) {
                    NSArray *letterArray = [sectionedDataSource objectAtIndex:i];
                    if ([[[letterArray lastObject] name] characterAtIndex:0] ==
                        [location.name characterAtIndex:0]) {
                        
                        NSMutableArray *mutLetArr = [letterArray mutableCopy];
                        [mutLetArr addObject:location];
                        NSArray *newLetterArray = [mutLetArr copy];
                        [sectionedDataSource setObject:newLetterArray atIndexedSubscript:i];
                        found = true;
                    }
                }
                if (!found) {
                    [sectionedDataSource addObject:[NSArray arrayWithObject:location]];
                }
            }
            
            // If nearness sort
            else if ([sortIdentifier isEqualToString:kSortIdentifierNear]) {
                int index;
                double miles = [location.distance doubleValue] / METERS_PER_MILE;
                if (miles <= .05) index = 0;
                else if (miles <= .1) index = 1;
                else if (miles <= .25) index = 2;
                else if (miles <= .5) index = 3;
                else if (miles <= 1) index = 4;
                else if (miles <= 2) index = 5;
                else index = 6;
                
                NSMutableArray *mutDistArr =
                [[sectionedDataSource objectAtIndex:index] mutableCopy];
                [mutDistArr addObject:location];
                NSArray *newDistArray = [mutDistArr copy];
                [sectionedDataSource setObject:newDistArray
                            atIndexedSubscript:index];
            }
            else if ([sortIdentifier isEqualToString:kSortIdentifierCategory]) {
                
                NSMutableArray *arr = [categories objectForKey:location.type];
                if (!arr) {
                    [categories setObject:
                     [NSMutableArray  arrayWithObject:location]
                                   forKey:location.type];
                } else [arr addObject:location];
                
            }
        }
    }
    
    if ([sortIdentifier isEqualToString:kSortIdentifierCategory]) {
        for (id category in categories) {
            [sectionedDataSource addObject:
             [[categories objectForKey:category] copy]];
        }
    }
    
    self.dataSource = [sectionedDataSource copy];
    for (NSArray *section in self.dataSource) {
        if ([section count] == 0) {
            [sectionedDataSource removeObject:section];
        }
    }
    self.dataSource = [sectionedDataSource copy];
    self.sortIdentifier = sortIdentifier;
}

// Sort data in alphabetical order. Takes old dataSource.
- (NSArray *)sortDataAlphabetical:(NSMutableArray *)array {
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] characterAtIndex:0] > [[obj2 name] characterAtIndex:0];
    }];
    return [array copy];
}

// Sort data based on nearby. Takes old dataSource.
- (NSArray *)sortDataNear:(NSMutableArray *)array {
    CLLocation *userLoc = [self.locManager location];
    CLLocation *otherLoc;
    
    for (DLocation *location in array) {
        otherLoc = [[CLLocation alloc] initWithLatitude:
                    [location.latitude doubleValue]
                                              longitude:
                    [location.longitude doubleValue]];
        location.distance =
        [NSNumber numberWithDouble:[userLoc distanceFromLocation:otherLoc]];
    }
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 distance] doubleValue] > [[obj2 distance] doubleValue];
    }];
    return [array copy];
}

#pragma mark - User interface

// Private method to customize the UI. Typically called in viewDidLoad
- (void)customizeUI {

    // Set a gradient on the Tab Bar
    [SAViewManipulator setGradientBackgroundImageForView:self.tabBarController.tabBar withTopColor:nil andBottomColor:nil];
    
    // Set a gradient on tab bar selection indicator
    [SAViewManipulator setGradientBackgroundImageForView:self.tabBarController.tabBar.selectionIndicatorImage withTopColor:[UIColor whiteColor] andBottomColor:[UIColor whiteColor]];
    
    // Custom left bar-button item
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonWithImage:[UIImage imageNamed:@"20-gear2" withColor:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(optionsPressed:)];
    UIView *lBBIView = self.navigationItem.leftBarButtonItem.customView;
    
    // Add a shadow to that bar-button item
    [SAViewManipulator addShadowToView:lBBIView withOpacity:.8 radius:1 andOffset:CGSizeMake(1, 1)];
    
    // Custom right bar-button item
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonWithImage:[UIImage imageNamed:@"71-compass" withColor:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(setWayPointToNearestLocation)];
    UIView *rBBIView = self.navigationItem.rightBarButtonItem.customView;
    
    // Add a shadow to that bar-button item
    [SAViewManipulator addShadowToView:rBBIView withOpacity:.8 radius:1 andOffset:CGSizeMake(-1, 1)];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VMDiningCell";
 
    // Try to dequeue a reusable cell
    VMDListCell *cell = (VMDListCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    DLocation *location = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.nameLabel.text = location.name;
    cell.categoryLabel.text = location.type;
    if (indexPath.row % 2) {
        cell.cellBg.backgroundColor = [UIColor whiteColor];
    } else cell.cellBg.backgroundColor = [UIColor lightGrayColor];
    
    if ([location distance]) {
        cell.distanceLabel.text = [self formatDistanceToMiles:location.distance];
    }
    cell.delegate = self;
    
//    cell.selectedBackgroundView = cell.cellBg;
//    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"FFDB4D"];
    
    return cell;
}

/* Commented out for now, may find use for later.
- (void)sortData:(NSString *)sortType
{
	NSSortDescriptor *locationSortDescriptor;

	if ([sortType isEqualToString:@"Near"]) {
		locationSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	} else if ([sortType isEqualToString:@"A-Z"]) {
		locationSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	
	}
	
//	NSArray * descriptors = @[locationSortDescriptor];
//	NSArray * sortedArray = [self.dataSource sortedArrayUsingDescriptors:descriptors];
}
*/


#pragma mark - UITableView Delegate

// custom view for header. will be adjusted to default or specified header height 
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    VMDSectionHeaderView *sHV = [[VMDSectionHeaderView alloc] init];
    sHV.headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [SAViewManipulator addBorderToView:sHV withWidth:1 color:[UIColor lightGrayColor] andRadius:0];
    return sHV;
}

// Titles for section headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Alphabetical sort
    if ([self.sortIdentifier isEqualToString:kSortIdentifierAlphabetical]) {
        return [NSString stringWithFormat:@"%c", [[[[self.dataSource objectAtIndex:section] lastObject] name] characterAtIndex:0]];
    }
    // Nearness sort
    else if ([self.sortIdentifier isEqualToString:kSortIdentifierNear]) {
        float y;
        NSArray *distances = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.05], [NSNumber numberWithFloat:.1], [NSNumber numberWithFloat:.25], [NSNumber numberWithFloat:.5], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil];
        NSNumber *num = [distances objectAtIndex:section];
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setMaximumFractionDigits:2];
        
        y = [[distances objectAtIndex:section] floatValue];
        
        if (y > 2) {
            return [NSString stringWithFormat:@">%d miles", 2];
        }
        
        return [NSString stringWithFormat:@"%@ miles", [numFormatter stringFromNumber:num]];
    }
    // Categorical sort
    else if ([self.sortIdentifier isEqualToString:kSortIdentifierCategory]) {
        DLocation *loc = [[self.dataSource objectAtIndex:section] lastObject];
        return loc.type;
    }
    return @" ";
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"VMDListToDetail" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBActions

- (IBAction)optionsPressed:(UIBarButtonItem *)sender {
    if (self.appDelegate.viewController.isOpen) {
        [self.appDelegate.viewController closeSlider:YES completion:nil];
    } else {
        [self.appDelegate.viewController openSlider:YES completion:nil];
    }
}

- (IBAction)refreshData:(UIBarButtonItem *)sender {
    [self configureDataWithSortIdentifier:self.sortIdentifier];
    [self.tableView reloadData];
}

#pragma mark - Storyboard segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.appDelegate.viewController setLocked:YES];
    
    // Get the destination view controller from the segue
    VMDLocationDetailVC *destination = [segue destinationViewController];
    
    // Grab the index of the object selected
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    // Deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Set the destination's location property
    DLocation *loc = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // Set the title
    destination.title = loc.type;

    destination.location = loc;
}

#pragma mark - CLLocationManagerDelegate

// Cartesian distance
- (double)distanceWithXOne:(double)x1 yOne:(double)y1 xTwo:(double)x2 yTwo:(double)y2 {
    return sqrt(pow((x2-x1), 2.0) + pow((y2-y1), 2.0));
}

- (void)locationManager:(CLLocationManager *)manager
didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0) {
    

//        // Directed location
//        DLocation *location = self.directingLocation;
//        NSLog(@"Pointing to %@", location.name);
//        
//        // Me
//        double x1 = self.locManager.location.coordinate.latitude;
//        double y1 = self.locManager.location.coordinate.longitude;
//        
//        // Location
//        double x2 = [location.latitude floatValue];
//        double y2 = [location.longitude floatValue];
//        
//        // Third triangle point
//        double x3 = x1;
//        double y3 = y2;
//        
//        // Sides of the triangle
//        double meToLocation = [self distanceWithXOne:x1 yOne:y1 xTwo:x2 yTwo:y2];
//        double meToVertPoint = [self distanceWithXOne:x1 yOne:y1 xTwo:x3 yTwo:y3];
//        
//        NSLog(@"Magnetic heading: %f", newHeading.magneticHeading);
//        NSLog(@"Heading accuracy: %f", newHeading.headingAccuracy);
//        
//        // Angle between place and north
//        double angle = acosf(meToVertPoint/meToLocation);
//        
//        if (y2 < y1) {
//            angle = -angle;
//        }
//        if (x2 < x1) {
//            if (angle >= 0)
//                angle = M_PI - angle;
//            else
//                angle = -M_PI - angle;
//        }

    CLLocation *destination = [CLLocation locationWithCoordinate:
                               CLLocationCoordinate2DMake(self.directingLocation.latitude.doubleValue,
                                                          self.directingLocation.longitude.doubleValue)];
    
    double rotationAngle =
    [self.locManager.location bearingInRadiansTowardsLocation:destination] -
    newHeading.magneticHeading * ((double)M_PI/(double)180.0);
    
    // Create rotation transform based on heading
//    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
//    rotationTransform = CGAffineTransformRotate(rotationTransform, rotationAngle);
    
    // Create 3D Affine Transform based on pitch of device
    CMAttitude *attitude = self.motionManager.deviceMotion.attitude;
//    CATransform3D transform3D =
//    CATransform3DMakeRotation(attitude.pitch, 0, 1, 0);
    CATransform3D transform;
    transform = CATransform3DMakeRotation(attitude.pitch, 1, 0, 0);
    transform = CATransform3DRotate(transform, attitude.roll, 0, 1, 0);
    transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1);
    
    // Combine the two affine transforms
//    CGAffineTransform combineTransforms =
//    CGAffineTransformConcat(CATransform3DGetAffineTransform(transform), rotationTransform);
    
    // Transform the imageView
    self.directionImageView.transform = CATransform3DGetAffineTransform(transform);
    
}

// Location update
- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0) {
    
    // Copy the datasource for comparison
    NSArray *dataSourceCopy = [self.dataSource copy];
    
    // Sort data again
    [self configureDataWithSortIdentifier:self.sortIdentifier];
    
    // If the newly sorted data is different, reload the tableView with it
    if (![dataSourceCopy isEqualToArray:self.dataSource]) {
        [self.tableView reloadData];
        
        // If the we have a location to direct to,
        if (!self.directingLocation) {
            if ([self.sortIdentifier isEqualToString:kSortIdentifierNear] &&
                self.directingLocation != [[self.dataSource objectAtIndex:0]
                                           objectAtIndex:0]) {
                    self.directingLocation = [[self.dataSource objectAtIndex:0]
                                              objectAtIndex:0];
                    
                }
        }
    }
    
    if (![self.nearestDistance.text isEqualToString:[self formatDistanceToMiles:self.directingLocation.distance]]) {
        [self updateDistance];
    }
}

- (void)updateDistance {
    self.nearestDistance.text =
    [self formatDistanceToMiles:self.directingLocation.distance];
}

- (void)setWayPointToNearestLocation {
    
    [self setWayPointToLocation:
     [[self sortDataNear:[self.oldDataSource mutableCopy]]
       objectAtIndex:0]];
}

- (void)setWayPointToLocation:(DLocation *)location {
    self.directingLocation = location;
    
    // Update information on the view at the top of the tableView
    self.nearestNameLabel.text = self.directingLocation.name;
    self.nearestCategoryLabel.text = self.directingLocation.type;
    
    // display it
    self.nearestDistance.text = [self formatDistanceToMiles:location.distance];
    
    [self locationManager:self.locManager didUpdateHeading:self.locManager.heading];
}

- (NSString *)formatDistanceToMiles:(NSNumber *)distance {
    NSNumber *num = [NSNumber numberWithFloat:(distance.floatValue / METERS_PER_MILE)];
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setMaximumIntegerDigits:1];
    [numFormatter setMaximumFractionDigits:2];
    
    // display it
    return [NSString stringWithFormat:@"%@", [numFormatter stringFromNumber:num]];
}

@end
