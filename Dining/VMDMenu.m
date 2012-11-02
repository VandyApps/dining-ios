//
//  VMDMenu.m
//  Dining
//
//  Created by Scott Andrus on 11/1/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDMenu.h"

@implementation VMDMenu

- (id)initWithLocation:(DLocation *)location date:(NSDate *)date content:(NSDictionary *)mealPeriods
{
    self = [super init];
    if (self) {
        self.location = location;
        self.date = date;
        self.mealPeriods = mealPeriods;
    }
    return self;
}

@end
