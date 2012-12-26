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
    
    OptionPair *optionsPair = [[OptionPair alloc] init];
    optionsPair.header = @"Options";
    optionsPair.array = [NSArray arrayWithObjects:@"Item 1", @"Item 2", nil];
    
    OptionPair *accountPair = [[OptionPair alloc] init];
    accountPair.header = @"Account";
    accountPair.array = [NSArray arrayWithObjects:@"Item 1", @"Item 2", @"Item 3", nil];
    
    [mutableOptions addObject:optionsPair];
    [mutableOptions addObject:accountPair];
    
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
    
    cell.textLabel.text = [[[self.options objectAtIndex:indexPath.section] array] objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    cell.textLabel.shadowColor = [UIColor darkTextColor];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.options.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.options objectAtIndex:section] header];
}

- (void)viewDidUnload {
    [self setHeaderScrollView:nil];
    [self setNameLabel:nil];
    [self setProfilePicture:nil];
    [self setInfoView:nil];
    [super viewDidUnload];
}
@end
