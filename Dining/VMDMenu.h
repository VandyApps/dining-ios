//
//  VMDMenu.h
//  Dining
//
//  Created by Scott Andrus on 11/1/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLocation.h"

@interface VMDMenu : NSObject

@property (strong, nonatomic) DLocation *location;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *dateString;

// Meal Periods:
// Breakfast - Lunch - Dinner - FourthMeal
@property (strong, nonatomic) NSDictionary *mealPeriods;

- (id)initWithLocation:(DLocation *)location date:(NSDate *)date content:(NSDictionary *)mealPeriods;

@end
