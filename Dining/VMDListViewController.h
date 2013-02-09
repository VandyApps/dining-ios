//
//  VMDListViewController.h
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#import "VMDAppDelegate.h"
#import "VMDTabBarController.h"
#import "DLocation.h"
#import "PullToRefreshView.h"
#import "VMDListCell.h"

@interface VMDListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, PullToRefreshViewDelegate, VMDListCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *featuredCellContainerView;
@property (strong, nonatomic) IBOutlet UIButton *featuredCellButton;
@property (strong, nonatomic) IBOutlet UILabel *nearestDistance;
@property (strong, nonatomic) IBOutlet UIImageView *directionImageView;
@property (strong, nonatomic) IBOutlet UILabel *nearestNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *nearestCategoryLabel;


// Two-dimensional array of NSArrays of DLocations
@property (strong, nonatomic) NSArray *dataSource;

// One-dimensional array of Dlocations
@property (strong, nonatomic) NSArray *oldDataSource;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) VMDAppDelegate *appDelegate;
@property (strong, nonatomic) VMDTabBarController *vmdTBC;
@property (strong, nonatomic) NSString *sortIdentifier;
@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) DLocation *directingLocation;

- (void)configureDataWithSortIdentifier:(NSString *)sortIdentifier;

@end
