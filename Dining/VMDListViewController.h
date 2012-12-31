//
//  VMDListViewController.h
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMDAppDelegate.h"
#import "VMDTabBarController.h"

@interface VMDListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *featuredCellContainerView;
@property (strong, nonatomic) IBOutlet UIButton *featuredCellButton;

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) VMDAppDelegate *appDelegate;
@property (strong, nonatomic) VMDTabBarController *vmdTBC;

@end
