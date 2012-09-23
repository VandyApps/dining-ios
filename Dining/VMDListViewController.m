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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DLocation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.dataSource = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
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

#pragma mark - User interface

- (void)customizeUI {
    self.featuredCellContainerView.layer.borderColor = [[UIColor darkTextColor] CGColor];
    self.featuredCellContainerView.layer.borderWidth = .5;
    
    self.featuredCellView.layer.cornerRadius = 8;
    self.featuredCellView.layer.borderColor = [[UIColor darkTextColor] CGColor];
    self.featuredCellView.layer.borderWidth = .5;
//    [SAImageManipulator addShadowToView:self.featuredCellView withOpacity:.8 radius:2 andOffset:CGSizeMake(-1, -1)];
    
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
    static NSString *CellIdentifier = @"VMDiningCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Storyboard segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    VMDLocationDetailVC *destination = [segue destinationViewController];
    destination.title = [[self.dataSource objectAtIndex:[self.tableView indexPathForCell:sender].row] name];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    // Deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Set the destination's location property
    DLocation *loc = [self.dataSource objectAtIndex:indexPath.row];
    destination.location = loc;
}

@end
