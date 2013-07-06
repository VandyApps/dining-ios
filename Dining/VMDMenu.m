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
        _location = location;
        _date = date;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM d, yyyy"];
        
        _dateString = [formatter stringFromDate:date];
        
        _mealPeriods = [mealPeriods mutableCopy];;
    }
    return self;
}

@end
