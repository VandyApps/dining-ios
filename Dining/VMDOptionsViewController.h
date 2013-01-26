//
//  VMDOptionsViewController.h
//  Dining
//
//  Created by Scott Andrus on 10/20/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSSlidingViewController.h"

@interface VMDOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JSSlidingViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *headerScrollView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIView *infoView;

@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSMutableArray *selectedOptions;
@property (strong, nonatomic) NSString *sortSelected;
@property (strong, nonatomic) id appDelegate;

@end
