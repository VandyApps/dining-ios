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
	
	NSArray *hoursArray = [self parseHoursFromString:hours];
	
	//NSLog(hours);
	NSLog(@"Hi");
	
	return YES;
}

// Generates a String array from a String containing a comma- and semicolon-separated list of times
// Ported from Matt's Android code
- (NSArray *)parseHoursFromString:(NSString *)string {
	
    if ([string isEqualToString:@"null\n"] || [string isEqualToString:@"null"]) {
        return nil;
    }
    
    NSArray *semicolonArray = [string componentsSeparatedByString:@";"];
    NSArray *commaArray;
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *timeRange in semicolonArray) {
        commaArray = [timeRange componentsSeparatedByString:@","];
        for (NSString *time in commaArray) {
            [result addObject:time];
        }
    }
    
    // Time formatter to accept those strings
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"k:mm"];
    
    NSMutableArray *dateHoursArray = [NSMutableArray array];
    for (NSString *str in result) {
        [dateHoursArray addObject:[timeFormatter dateFromString:str]];
    }
   
    return [dateHoursArray copy];
}

@end
