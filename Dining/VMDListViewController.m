//
//  VMDListViewController.m
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDListViewController.h"
#import "DLocation.h"
#import "VMDLocationDetailVC.h"
#import "SAViewManipulator.h"
#import "UIColor+i7HexColor.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

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

    // Grab the app delegate for use of the sliding view controller
    self.appDelegate = (VMDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Fetch the data from the Core Data context
    [self fetchDataFromContext];
    
    // Customize the UI
    [self customizeUI];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [[self.appDelegate viewController] setLocked:NO];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setFeaturedCellContainerView:nil];
    [self setFeaturedCellButton:nil];
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
    self.dataSource = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *mapItems = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    for (DLocation *location in self.dataSource) {
        if ([location isKindOfClass:[DLocation class]]) {
//            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]) addressDictionary:nil]];
//            mapItem.name = location.name;
//            [mapItems addObject:mapItem];
            [mapItems addObject:location];
        }
    }
    self.vmdTBC.mapItems = [mapItems copy];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
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
    DLocation *location = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = location.type;
    
    return cell;
}

- (void)sortData:(NSString *)sortType
{
	NSSortDescriptor *locationSortDescriptor;

	if ([sortType isEqualToString:@"Near"]) {
		locationSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	} else if ([sortType isEqualToString:@"A-Z"]) {
		locationSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	
	}
	
	NSArray * descriptors = @[locationSortDescriptor];
	NSArray * sortedArray = [self.dataSource sortedArrayUsingDescriptors:descriptors];

	
	
}

#pragma mark - UITableView Delegate



#pragma mark - IBActions

- (IBAction)optionsPressed:(UIBarButtonItem *)sender {
    [self.appDelegate.viewController openSlider:YES completion:nil];
}


#pragma mark - Storyboard segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[self.appDelegate viewController] setLocked:YES];
    
    // Get the destination view controller from the segue
    VMDLocationDetailVC *destination = [segue destinationViewController];
    
    // Grab the index of the object selected
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    // Deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Set the destination's location property
    DLocation *loc = [self.dataSource objectAtIndex:indexPath.row];
    
    // Set the title
    destination.title = loc.type;

    destination.location = loc;
}

@end
