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
    
//    self.navigationController.title = self.tabBarController.tabBarItem.title;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DLocation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.dataSource = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - User interface

- (void)customizeUI {

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
        
//        DLocation *loc = [self.dataSource objectAtIndex:indexPath.row];
    
//        destination.location = loc;
}

@end
