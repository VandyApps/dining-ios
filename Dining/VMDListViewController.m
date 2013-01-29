//
//  VMDListViewController.m
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDListViewController.h"
#import "VMDLocationDetailVC.h"
#import "SAViewManipulator.h"
#import "UIColor+i7HexColor.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#define METERS_PER_MILE 1609.344
#define kSortIdentifierAlphabetical @"SORT_ID_ALPHABETICAL"
#define kSortIdentifierNear @"SORT_ID_NEAR"

@interface VMDListViewController ()

@end

@implementation VMDListViewController

@synthesize tableView;

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
    [self.locManager startUpdatingLocation];
    [self.locManager startUpdatingHeading];
    
//    self.directingLocation = [[self.dataSource objectAtIndex:1] objectAtIndex:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [[self.appDelegate viewController] setLocked:NO];
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
    
    // Alphabetical
    if ([sortIdentifier isEqualToString:kSortIdentifierAlphabetical]) {
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
                int miles = [location.distance doubleValue] / METERS_PER_MILE;
                if (miles <= .25) index = 0;
                else if (miles <= .5) index = 1;
                else if (miles <= 1) index = 2;
                else if (miles <= 5) index = 3;
                else if (miles <= 10) index = 4;
                else if (miles <= 20) index = 5;
                else index = 6;
                
                NSMutableArray *mutDistArr =
                [[sectionedDataSource objectAtIndex:index] mutableCopy];
                [mutDistArr addObject:location];
                NSArray *newDistArray = [mutDistArr copy];
                [sectionedDataSource setObject:newDistArray
                            atIndexedSubscript:index];
            }
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
    // Set borders and corner radius for cell container view and cell view
//    self.featuredCellContainerView.layer.borderColor = [[UIColor darkTextColor] CGColor];
//    self.featuredCellContainerView.layer.borderWidth = .5;
    
    // TODO: Make this less buggy
//    [SAViewManipulator addShadowToView:self.featuredCellView withOpacity:.8 radius:2 andOffset:CGSizeMake(-1, -1)];
    
    // Set a tabbar gradient
    [SAViewManipulator setGradientBackgroundImageForView:self.tabBarController.tabBar withTopColor:nil andBottomColor:nil];
    
//    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"MenuIcon"]];
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
    // Try to dequeue a reusable cell
    static NSString *CellIdentifier = @"VMDiningCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // If we can't, then allocate and initialize a new one
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    DLocation *location = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = location.type;
    
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

// Titles for section headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sortIdentifier == kSortIdentifierAlphabetical) {
        return [NSString stringWithFormat:@"%c", [[[[self.dataSource objectAtIndex:section] lastObject] name] characterAtIndex:0]];
    } else if (self.sortIdentifier == kSortIdentifierNear) {
        float y;
        NSArray *distances = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.25], [NSNumber numberWithFloat:.5], [NSNumber numberWithInt:1], [NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:20], [NSNumber numberWithInt:21], nil];
        NSNumber *num = [distances objectAtIndex:section];
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setMaximumFractionDigits:2];
        
        y = [[distances objectAtIndex:section] floatValue];
        
        if (y > 20) {
            return [NSString stringWithFormat:@">%d miles", 20];
        }
        
        return [NSString stringWithFormat:@"%@ miles", [numFormatter stringFromNumber:num]];
    }
    return @" ";
}

#pragma mark - IBActions

- (IBAction)optionsPressed:(UIBarButtonItem *)sender {
    [self.appDelegate.viewController openSlider:YES completion:nil];
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
- (float)distanceWithXOne:(float)x1 yOne:(float)y1 xTwo:(float)x2 yTwo:(float)y2 {
    return sqrtf(powf((x2-x1), 2.0) + powf((y2-y1), 2.0));
}

- (void)locationManager:(CLLocationManager *)manager
didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0) {
    
    // Directed location
    DLocation *location = self.directingLocation;
    NSLog(@"Pointing to %@", location.name);
    
    // Me
    float x1 = self.locManager.location.coordinate.latitude;
    float y1 = self.locManager.location.coordinate.longitude;
    
    // Location
    float x2 = [location.latitude doubleValue];
    float y2 = [location.longitude doubleValue];
    
    // Third triangle point
    float x3 = x1;
    float y3 = y2;
    
    // Sides of the triangle
    float meToLocation = [self distanceWithXOne:x1 yOne:y1 xTwo:x2 yTwo:y2];
    float meToVertPoint = [self distanceWithXOne:x1 yOne:y1 xTwo:x3 yTwo:y3];
    
    // Angle between me and north
    double angle = acosf(meToVertPoint/meToLocation);
    if (y3 < 0) angle += (M_PI/2);
    
    // Rotate directional image view to location.
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -newHeading.trueHeading * (M_PI/180.0) + angle + (M_PI));
    self.directionImageView.transform = rotationTransform;
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
    }
    
    // If we're in near mode and the first one is different, change it
    if (self.sortIdentifier == kSortIdentifierNear &&
        self.directingLocation != [[self.dataSource objectAtIndex:0]
                                   objectAtIndex:0]){
        self.directingLocation = [[self.dataSource objectAtIndex:0]
                                  objectAtIndex:0];
        
    }
    
    // If the we have a location to direct to,
    if (self.directingLocation) {
        // Update information on the view at the top of the tableView
        self.nearestNameLabel.text = self.directingLocation.name;
        self.nearestCategoryLabel.text = self.directingLocation.type;
        
        // Get the other location
        CLLocation *otherLoc = [[CLLocation alloc] initWithLatitude:
                                [self.directingLocation.latitude doubleValue]
                                                          longitude:
                                [self.directingLocation.longitude doubleValue]];
        
        // Format the number
        NSNumber *num = [NSNumber numberWithFloat:
                         [self.locManager.location
                          distanceFromLocation:otherLoc] / METERS_PER_MILE];
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setMaximumFractionDigits:2];
        
        // idsplay it
        self.nearestDistance.text =
        [NSString stringWithFormat:@"%@", [numFormatter stringFromNumber:num]];
    }
    
    
}

@end
