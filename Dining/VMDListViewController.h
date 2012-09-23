//
//  VMDListViewController.h
//  Dining
//
//  Created by Scott Andrus on 9/15/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMDListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
