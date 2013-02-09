//
//  VMDTabBarController.m
//  Dining
//
//  Created by Scott Andrus on 12/26/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDTabBarController.h"
#import "VMDListViewController.h"

#import "SAViewManipulator.h"

#define LoginIdentifier @"LoginSegue"

@interface VMDTabBarController ()

@end

@implementation VMDTabBarController

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
    
    self.loggedIn = NO;
    for (id viewController in self.viewControllers) {
        [(id)[viewController visibleViewController] setVmdTBC:self];
    }
    
    self.tabBar.backgroundImage = [[UIImage imageNamed:@"VMDining_tab_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40) resizingMode:UIImageResizingModeStretch];
    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"VMDining_tab_bar_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40) resizingMode:UIImageResizingModeStretch];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    // If the user is not yet logged in...
//    if (!self.loggedIn) {
//        
//        // Present the login VC via a segue
//        [self performSegueWithIdentifier:LoginIdentifier sender:self];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:LoginIdentifier]) {
        [segue.destinationViewController setDelegate:sender];
    }
}

@end
