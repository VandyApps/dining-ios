//
//  VMDLoginViewController.m
//  Dining
//
//  Created by Scott Andrus on 12/26/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDLoginViewController.h"
#import "VMDTabBarController.h"
#import "SAViewManipulator.h"
#import "UIColor+i7HexColor.h"

@interface VMDLoginViewController ()

@end

@implementation VMDLoginViewController

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
    
    [self customizeInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface

- (void)customizeInterface {
    [SAViewManipulator setGradientBackgroundImageForView:self.view withTopColor:[UIColor colorWithHexString:@"FFDD47"] andBottomColor:[UIColor colorWithHexString:@"E3A829"]];
}

#pragma mark - IBActions

- (IBAction)loginPressed {
    [self.delegate setLoggedIn:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)continuePressed:(id)sender {
    [self.delegate setLoggedIn:YES];
}


@end
