//
//  VMDOptionsViewController.m
//  Dining
//
//  Created by Scott Andrus on 10/20/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDOptionsViewController.h"
#import "SAViewManipulator.h"
#import "UIColor+i7HexColor.h"
#import "UIView+Frame.h"
#import "OptionPair.h"
#import "SectionHeaderView.h"

#import <QuartzCore/QuartzCore.h>

@interface VMDOptionsViewController ()

@end

@implementation VMDOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self populateOptions];
    [self customizeInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Options configuration

- (void)populateOptions {
    NSMutableArray *mutableOptions = [NSMutableArray arrayWithCapacity:5];
    
    OptionPair *sortListPair = [[OptionPair alloc] init];
    sortListPair.header = @"SORT LIST";
    sortListPair.array = [NSArray arrayWithObjects:@"Near", @"A-Z", nil];
    
    OptionPair *filterListPair = [[OptionPair alloc] init];
    filterListPair.header = @"FILTER LIST";
    filterListPair.array = [NSArray arrayWithObjects:@"Dining Halls", @"Meal Plan", @"Munchie Marts", @"Open", nil];
    
    OptionPair *filterMapPair = [[OptionPair alloc] init];
    filterMapPair.header = @"FILTER MAP";
    filterMapPair.array = [NSArray arrayWithObjects:@"Dining Halls", @"Meal Plan", @"Munchie Marts", @"Open", nil];
    
    [mutableOptions addObject:sortListPair];
    [mutableOptions addObject:filterListPair];
    [mutableOptions addObject:filterMapPair];
    
    self.options = [mutableOptions copy];
}

#pragma mark - Interface 

- (void)customizeInterface {
    [SAViewManipulator setGradientBackgroundImageForView:self.view withTopColor:[UIColor colorWithHexString:@"545454"] andBottomColor:nil];
    self.headerScrollView.contentSize = CGSizeMake(self.headerScrollView.width * 2, self.headerScrollView.height);
    self.headerScrollView.contentOffset = CGPointMake(self.headerScrollView.width, 0);
    self.profilePicture.left += self.headerScrollView.width;
    self.nameLabel.left += self.headerScrollView.width;
    
    [SAViewManipulator addBorderToView:self.profilePicture withWidth:2 color:[UIColor whiteColor] andRadius:0];
}

#pragma mark - TableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.options objectAtIndex:section] array] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if ([[[self.options objectAtIndex:indexPath.section] header] isEqualToString:@"SORT LIST"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [[[self.options objectAtIndex:indexPath.section] array] objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:17.0f];
    cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    cell.textLabel.shadowColor = [UIColor darkTextColor];
    
    return cell;
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[self.options objectAtIndex:indexPath.section] header] isEqualToString:@"SORT LIST"]) {
        
        for (int i = 0; i < self.options.count; ++i) {
            if ([[[self.options objectAtIndex:i] header] isEqualToString:@"SORT LIST"]) {
                for (int j = 0; j < [[[self.options objectAtIndex:i] array] count]; ++j) {
                    
                    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:oldIndexPath];
                    
                    // If another cell is selected, deselect it.
                    if ([cell isSelected]) {
                        [tableView deselectRowAtIndexPath:oldIndexPath animated:YES];
                        [self tableView:tableView didDeselectRowAtIndexPath:oldIndexPath];
                    }
                    
                }
            }
        }
        
    }
    
    return indexPath;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[[self.options objectAtIndex:indexPath.section] header] isEqualToString:@"SORT LIST"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *selind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SelectionIndicator"]];
        cell.accessoryView = selind;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    [tableView cellForRowAtIndexPath:indexPath].accessoryView = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.options.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.options objectAtIndex:section] header];
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionHeaderView *container = [SectionHeaderView new];
    
    // Load the top-level objects from the custom cell XIB.
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView" owner:self options:nil];
    
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    container = [topLevelObjects objectAtIndex:0];
    
    container.layer.borderColor = [UIColor darkTextColor].CGColor;
    container.layer.borderWidth = 0.5f;
    
    NSString *title = [self tableView:self.tableView titleForHeaderInSection:section];
    container.label.text = title;
    
    [SAViewManipulator setGradientBackgroundImageForView:container withTopColor:[UIColor colorWithHexString:@"757575"] andBottomColor:[UIColor colorWithHexString:@"4F4F4F"]];
    return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25;
}

- (void)viewDidUnload {
    [self setHeaderScrollView:nil];
    [self setNameLabel:nil];
    [self setProfilePicture:nil];
    [self setInfoView:nil];
    [super viewDidUnload];
}
@end
