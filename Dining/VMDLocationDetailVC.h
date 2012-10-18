//
//  VMDLocationDetailVC.h
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLocation.h"

@interface VMDLocationDetailVC : UIViewController <UIScrollViewDelegate>

// Up top
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;

// Middle
@property (strong, nonatomic) IBOutlet UIScrollView *dateScrollView;
@property (strong, nonatomic) IBOutlet UILabel *dayLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UIButton *dateLeftButton;
@property (strong, nonatomic) IBOutlet UIButton *dateRightButton;
@property (strong, nonatomic) IBOutlet UIView *titleOverlayView;


// Bottom
@property (strong, nonatomic) IBOutlet UIScrollView *mealScrollView;
@property (strong, nonatomic) IBOutlet UILabel *mealLabel;
@property (strong, nonatomic) IBOutlet UIButton *mealRightButton;
@property (strong, nonatomic) IBOutlet UIButton *mealLeftBurron;

// Data model object
@property (strong, nonatomic) DLocation *location;

// To keep track of the currently selected weekday
@property int currentlySelectedWeekday;
@property int currentlySelectedMealPeriod;

@end
