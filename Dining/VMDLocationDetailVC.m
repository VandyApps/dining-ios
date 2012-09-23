//
//  VMDLocationDetailVC.m
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDLocationDetailVC.h"

@interface VMDLocationDetailVC ()

@end

@implementation VMDLocationDetailVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameLabel:nil];
    [super viewDidUnload];
}
@end
