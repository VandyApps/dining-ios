//
//  VMDTabBarController.m
//  Dining
//
//  Created by Scott Andrus on 12/26/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDTabBarController.h"

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
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // If the user is not yet logged in...
    if (!self.loggedIn) {
        
        // Present the login VC via a segue
        [self performSegueWithIdentifier:LoginIdentifier sender:self];
    }
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
