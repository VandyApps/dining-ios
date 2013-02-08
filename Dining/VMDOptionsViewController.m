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

#import "VMDListViewController.h"
#import "VMDMapViewController.h"

#import <QuartzCore/QuartzCore.h>

#define kSortIdentifierAlphabetical @"SORT_ID_ALPHABETICAL"
#define kSortIdentifierNear @"SORT_ID_NEAR"
#define kSortIdentifierCategory @"SORT_ID_CATEGORY"
#define kSortByHeader @"Sort By"
#define kFilterHeader @"Filter"

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
    
    self.selectedOptions = [NSMutableArray array];
    self.sortSelected = kSortIdentifierNear;
    
    [self customizeInterface];
    
    // Grab the app delegate for use of the sliding view controller
    self.appDelegate = (VMDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.appDelegate viewController] setDelegate:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Options configuration

- (void)populateOptions {
    NSMutableArray *mutableOptions = [NSMutableArray arrayWithCapacity:5];
    
    VMDAppDelegate *aD = self.appDelegate;
    VMDTabBarController *vmdtbc = aD.frontVC;
    UINavigationController *selectedNC = (UINavigationController *)vmdtbc.selectedViewController;
    id selectedVC = selectedNC.topViewController;
    
    NSArray *filters = [NSArray arrayWithObjects:@"Dining Halls", @"Meal Plan", @"Munchie Marts", @"Open", nil];
    
    if ([selectedVC isKindOfClass:[VMDListViewController class]]) {
        OptionPair *sortListPair = [[OptionPair alloc] init];
        sortListPair.header = kSortByHeader;
        sortListPair.array =
        [NSArray arrayWithObjects:@"Near", @"A-Z", @"Category", nil];
        
        OptionPair *filterListPair = [[OptionPair alloc] init];
        filterListPair.header = kFilterHeader;
        filterListPair.array = filters;
        
        [mutableOptions addObject:sortListPair];
        [mutableOptions addObject:filterListPair];
    } else if ([selectedVC isKindOfClass:[VMDMapViewController class]]) {
        OptionPair *filterMapPair = [[OptionPair alloc] init];
        filterMapPair.header = kFilterHeader;
        filterMapPair.array = filters;
        
        [mutableOptions addObject:filterMapPair];
    }
    
    self.options = [mutableOptions copy];
    [self.tableView reloadData];
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
    
    if ([[[self.options objectAtIndex:indexPath.section] header] isEqualToString:kSortByHeader]) {
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
    if ([[[self.options objectAtIndex:indexPath.section] header] isEqualToString:kSortByHeader]) {
        
        for (int i = 0; i < self.options.count; ++i) {
            if ([[[self.options objectAtIndex:i] header] isEqualToString:kSortByHeader]) {
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
    if (![[[self.options objectAtIndex:indexPath.section] header]
          isEqualToString:kSortByHeader]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [self.selectedOptions addObject:cell.textLabel.text];
            UIImageView *selind = [[UIImageView alloc] initWithImage:
                                   [UIImage imageNamed:@"SelectionIndicator"]];
            cell.accessoryView = selind;
        }
    } else {
        NSString *sortIdentifier = [[[self.options objectAtIndex:indexPath.section] array]
                                    objectAtIndex:indexPath.row];
        if ([sortIdentifier isEqualToString:@"A-Z"]) {
            self.sortSelected = kSortIdentifierAlphabetical;
        } else if ([sortIdentifier isEqualToString:@"Near"]) {
            self.sortSelected = kSortIdentifierNear;
        } else if ([sortIdentifier isEqualToString:@"Category"]) {
            self.sortSelected = kSortIdentifierCategory;
        }
        
        [[self.appDelegate viewController] closeSlider:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.selectedOptions removeObject:cell.textLabel.text];
    cell.accessoryView = nil;
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


#pragma mark - JSSlidingViewControllerDelegate

- (void)slidingViewControllerDidOpen:(JSSlidingViewController *)viewController {
    if ([self.sortSelected isEqualToString:@"Near"]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:0];
    } else if ([self.sortSelected isEqualToString:@"A-Z"]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:0];
    } else if ([self.sortSelected isEqualToString:@"Category"]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:0];
    }
    
    [self populateOptions];
}

- (void)slidingViewControllerDidClose:(JSSlidingViewController *)viewController {
    id tbcsvc = [(UINavigationController *)[[self.appDelegate frontVC] selectedViewController] visibleViewController];
    if ([tbcsvc isKindOfClass:[VMDListViewController class]]) {
        VMDListViewController *lvc = tbcsvc;
        if (![self.sortSelected isEqualToString:lvc.sortIdentifier]) {
            [lvc configureDataWithSortIdentifier:self.sortSelected];
            [lvc.tableView reloadData];
        }
    }
    
}
@end
