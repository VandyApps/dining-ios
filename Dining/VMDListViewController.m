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

#define kFilterIdentifierDining @"FILTER_ID_DINING"
#define kFilterIdentifierMealPlan @"FILTER_ID_MEALPLAN"
#define kFilterIdentifierMunchie @"FILTER_ID_MUNCHIE"
#define kFilterIdentifierOpen @"FILTER_ID_OPEN"

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
    self.locManager.headingFilter = kCLHeadingFilterNone;
    
    self.motionManager = [CMMotionManager new];
//    [self.motionManager startAccelerometerUpdates];
//    [self.motionManager startGyroUpdates];
	[self.motionManager startDeviceMotionUpdates];
    
	pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
	[pull setDelegate:self];
	[self.tableView addSubview:pull];
    if ([self.tableView respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)]) {
        [self.tableView registerClass:[VMDListCell class] forCellReuseIdentifier:@"VMDiningCell"];
    }
//    self.directingLocation = [[self.dataSource objectAtIndex:1] objectAtIndex:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self.appDelegate viewController] setLocked:NO];
    
    
    
//    VMDListCell *cell = [[VMDListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    UIGraphicsBeginImageContextWithOptions(cell.accessoryView.size, YES, [UIScreen mainScreen].scale);
//    [[cell.layer.sublayers objectAtIndex:1] renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *pngPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"Disclosure.png"];
//    // Write image to PNG
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
//    
//    // Create file manager
//    NSError *error;
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    
//    // Point to Document directory
//    NSString *docsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    
//    // Write out the contents of home directory to console
//    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:docsDirectory error:&error]);

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

- (UIView *)placeholderView
{
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:self.tableView.frame];
//        _placeholderView.backgroundColor = [UIColor lightGrayColor];
        [SAViewManipulator setGradientBackgroundImageForView:_placeholderView
                                                withTopColor:[UIColor colorWithHexString:@"6E6E6E"]
                                              andBottomColor:[UIColor colorWithHexString:@"424242"]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 2;
        label.text = @"Nothing to eat! Use fewer filters to see more options.";
        label.font = [UIFont fontWithName:@"Helvetica-Neue" size:30];
        label.textColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.shadowColor = [UIColor darkTextColor];
        label.size = [label.text sizeWithFont:label.font
                            constrainedToSize:CGSizeMake(250, 100)
                                lineBreakMode:UILineBreakModeWordWrap];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.left = _placeholderView.width / 2.0 - label.width / 2.0;
        label.top = _placeholderView.height / 2.0 - label.height / 2.0;
        [_placeholderView addSubview:label];
    }
    return _placeholderView;
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

#pragma mark - Data configuration and sorting

- (void)placeLocationInSection:(DLocation *)location
                  withSections:(NSMutableDictionary *)sections
         inSectionedDataSource:(NSMutableArray *)sectionedDataSource
                 andSectionKey:(NSString *)key {
    
    NSNumber *sectionExists = [sections objectForKey:key];
    
    if (sectionExists) {
        NSInteger index = [sectionExists integerValue];
        NSMutableArray *array = [[sectionedDataSource objectAtIndex:index] mutableCopy];
        [array addObject:location];
        [sectionedDataSource setObject:[array copy] atIndexedSubscript:index];
    } else {
        NSArray *array = [NSArray arrayWithObject:location];
        [sectionedDataSource addObject:array];
        [sections setObject:
         [NSNumber numberWithInt:[sectionedDataSource indexOfObject:array]]
                     forKey:key];
    }
    
}

- (void)placeLocation:(DLocation *)location
   nearWithDataSource:(NSMutableArray *)sectionedDataSource
{
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

- (void)filterDataWithFilterString:(NSString *)filterIdentifier
{
    NSMutableArray *newDataSource = [NSMutableArray array];
    for (__strong NSArray *section in self.dataSource) {
        NSMutableArray *newSection = [section mutableCopy];
        for (DLocation *location in section) {
            if ([filterIdentifier isEqualToString:@"Dining Halls"]) {
				if (![location.type isEqualToString:@"Dining Hall"])
                    [newSection removeObject:location];
			} else if ([filterIdentifier isEqualToString:@"Meal Plan"]) {
				if (!location.isMealPlan)
                    [newSection removeObject:location];
			} else if ([filterIdentifier isEqualToString:@"Munchie Marts"]) {
				if (![location.type isEqualToString:@"Munchie Mart"])
                    [newSection removeObject:location];
			} else if ([filterIdentifier isEqualToString:@"Open"]) {
				if (![location isOpen]) {
					[newSection removeObject:location];
				}
			}
        }
        if (newSection.count) {
            [newDataSource addObject:[newSection copy]];
        }
    }
    self.dataSource = [newDataSource copy];
    [self handlePlaceholderView];
}

- (void)handlePlaceholderView
{
    if (!self.dataSource.count) {
        if (![self.view.subviews containsObject:self.placeholderView]) {
            [self.view insertSubview:self.placeholderView
                        aboveSubview:self.tableView];
        }
    } else {
        [self.placeholderView removeFromSuperview];
    }
}

// Configures the data in the tableView based on the sortIdentifier
- (void)configureDataWithSortIdentifier:(NSString *)sortIdentifier {

    // The end-goal sectioned sorted array. Mutable for now.
    NSMutableArray *sectionedDataSource = [NSMutableArray array];
    
    // Sorted data array
    NSArray *sortedData;
    
    // Alphabetical (and Category)
    if ([sortIdentifier isEqualToString:kSortIdentifierAlphabetical] ||
        [sortIdentifier isEqualToString:kSortIdentifierCategory]) {
        
        // Sort the data in alphabetical order
        sortedData = [self sortDataAlphabetical:
                      [self.oldDataSource mutableCopy]];
    }
    
    // Near
    else if ([sortIdentifier isEqualToString:kSortIdentifierNear]) {
        
        // Sort data by nearness
        sortedData = [self sortDataNear:[self.oldDataSource mutableCopy]];
        
        // While we're here, add 7 sections
        for (int i = 0; i < 7; ++i) {
            [sectionedDataSource addObject:[NSArray array]];
        }
    }
    
    // Using a hash to remove duplicate locations
    NSMutableSet *hash = [NSMutableSet set];
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    
    for (DLocation *location in sortedData) {
        if (![hash containsObject:location.name]) {
            [hash addObject:location.name];
            
            // If nearness sort
            if ([sortIdentifier isEqualToString:kSortIdentifierNear]) {
                [self placeLocation:location
                 nearWithDataSource:sectionedDataSource];
            }
            else {
                NSString *key;
                if ([sortIdentifier isEqualToString:
                     kSortIdentifierAlphabetical]) {
                    key = [NSString stringWithFormat:@"%c",
                           [location.name characterAtIndex:0]];
                } else if ([sortIdentifier isEqualToString:
                            kSortIdentifierCategory]) {
                    key = location.type;
                }
                
                [self placeLocationInSection:location
                                withSections:sections
                       inSectionedDataSource:sectionedDataSource
                               andSectionKey:key];
            }
        }
    }
    self.dataSource = [self removeEmptySections:sectionedDataSource];
    self.sortIdentifier = sortIdentifier;
}

- (NSArray *)removeEmptySections:(NSMutableArray *)dataSource {
    NSMutableArray *array = [dataSource mutableCopy];
    // Remove empty sections
    for (NSArray *section in dataSource) {
        if ([section count] == 0) {
            [array removeObject:section];
        }
    }
    return [array copy];
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
//    [SAViewManipulator setGradientBackgroundImageForView:self.tabBarController.tabBar withTopColor:[UIColor colorWithHexString:@"666666"] andBottomColor:[UIColor colorWithHexString:@"333333"]];
    
    // Set a gradient on tab bar selection indicator
//    [SAViewManipulator setGradientBackgroundImageForView:self.tabBarController.tabBar.selectionIndicatorImage withTopColor:[UIColor whiteColor] andBottomColor:[UIColor whiteColor]];
    
    // Custom left bar-button item
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonWithImage:[UIImage imageNamed:@"20-gear2" withColor:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(optionsPressed:)];
    UIView *lBBIView = self.navigationItem.leftBarButtonItem.customView;
    
    // Add a shadow to that bar-button item
    [SAViewManipulator addShadowToView:lBBIView withOpacity:.8 radius:1 andOffset:CGSizeMake(0, 1)];
    
    // Custom right bar-button item
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonWithImage:[UIImage imageNamed:@"71-compass" withColor:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(setWayPointToNearestLocation)];
    UIView *rBBIView = self.navigationItem.rightBarButtonItem.customView;
    
    // Add a shadow to that bar-button item
    [SAViewManipulator addShadowToView:rBBIView withOpacity:.8 radius:1 andOffset:CGSizeMake(0, 1)];
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
    if (self.filters) {
        [self didReturnFromOptionsWithFilters:self.filters];
    }
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
    
    CLLocation *destination = [CLLocation locationWithCoordinate:
                               CLLocationCoordinate2DMake(self.directingLocation.latitude.doubleValue,
                                                          self.directingLocation.longitude.doubleValue)];
    
    double rotationAngle =
    [self.locManager.location bearingInRadiansTowardsLocation:destination] -
    newHeading.magneticHeading * ((double)M_PI/(double)180.0);
    
    // Create 3D Affine Transform based on pitch of device
    CMAttitude *attitude = self.motionManager.deviceMotion.attitude;
    CATransform3D transform;
    transform = CATransform3DMakeRotation(attitude.pitch, 1, 0, 0);
    transform = CATransform3DRotate(transform, attitude.roll, 0, 1, 0);
    transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1);
    
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

- (void)didReturnFromOptionsWithFilters:(NSArray *)filters
{
    self.filters = filters;
    // TODO: Implement
    for (NSString *filter in filters) {
        [self filterDataWithFilterString:filter];
    }
    if (!filters.count) {
        [self handlePlaceholderView];
    }
}

@end
