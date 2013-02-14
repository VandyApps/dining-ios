//
//  DLocation.m
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "DLocation.h"


@implementation DLocation

@dynamic name;
@dynamic latitude;
@dynamic longitude;
@dynamic sundayHours;
@dynamic mondayHours;
@dynamic tuesdayHours;
@dynamic wednesdayHours;
@dynamic thursdayHours;
@dynamic fridayHours;
@dynamic saturdayHours;
@dynamic detailDescription;
@dynamic isFavorite;
@dynamic type;
@dynamic url;
@dynamic phone;
@dynamic isMealMoney;
@dynamic isMealPlan;
@dynamic isOnCampus;
@dynamic locID;

@synthesize distance;

-(BOOL)isOpen
{
	NSLog(@"Hi");
	enum daysofweek {Sunday = 0, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday};
	
	NSDate* now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE"];
	
	NSString* day = [dateFormatter stringFromDate:now];
	NSString* hours;
	
	enum daysofweek curDay = day;
	
	switch (curDay) {
		case Sunday:
			hours = self.sundayHours;
			break;
		case Monday:
			hours = self.mondayHours;
			break;
		case Tuesday:
			hours = self.tuesdayHours;
			break;
		case Wednesday:
			hours = self.wednesdayHours;
			break;
		case Thursday:
			hours = self.thursdayHours;
			break;
		case Friday:
			hours = self.fridayHours;
			break;
		case Saturday:
			hours = self.saturdayHours;
			break;
		default:
			break;
	}
	
	//NSLog(hours);
	NSLog(@"Hi");
	
	return YES;
}

@end
