//
//  VMDLocationDetailVC.h
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLocation.h"

@interface VMDLocationDetailVC : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;

@property (strong, nonatomic) DLocation *location;

@end
