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
#import "SAImageManipulator.h"

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

    // Fetch the data from the Core Data context
    [self fetchDataFromContext];
    
    // Customize the UI
    [self customizeUI];
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setFeaturedCellContainerView:nil];
    [self setFeaturedCellView:nil];
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
}

#pragma mark - User interface

// Private method to customize the UI. Typically called in viewDidLoad
- (void)customizeUI {
    // Set borders and corner radius for cell container view and cell view
    self.featuredCellContainerView.layer.borderColor = [[UIColor darkTextColor] CGColor];
    self.featuredCellContainerView.layer.borderWidth = .5;
    
    self.featuredCellView.layer.cornerRadius = 8;
    self.featuredCellView.layer.borderColor = [[UIColor darkTextColor] CGColor];
    self.featuredCellView.layer.borderWidth = .5;
    
    // TODO: Make this less buggy
//    [SAImageManipulator addShadowToView:self.featuredCellView withOpacity:.8 radius:2 andOffset:CGSizeMake(-1, -1)];
    
    // Set a tabbar gradient
    [SAImageManipulator setGradientBackgroundImageForView:self.tabBarController.tabBar withTopColor:nil andBottomColor:nil];
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

#pragma mark - UITableView Delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

#pragma mark - Storyboard segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the destination view controller from the segue
    VMDLocationDetailVC *destination = [segue destinationViewController];
    
    // Set the title
    destination.title = [[self.dataSource objectAtIndex:[self.tableView indexPathForCell:sender].row] name];
    
    // Grab the index of the object selected
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    // Deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Set the destination's location property
    DLocation *loc = [self.dataSource objectAtIndex:indexPath.row];
    destination.location = loc;
}

@end
