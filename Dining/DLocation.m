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
	enum daysofweek {Sunday = 0, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday};
	
	NSDate* now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE"];
	
	NSString* day = [dateFormatter stringFromDate:now];
	NSString* hoursStr;
	
	int dayNum = [self numFromDay:day];
	
	enum daysofweek curDay = day;
	
	switch (dayNum) {
		case Sunday:
			hoursStr = self.sundayHours;
			break;
		case Monday:
			hoursStr = self.mondayHours;
			break;
		case Tuesday:
			hoursStr = self.tuesdayHours;
			break;
		case Wednesday:
			hoursStr = self.wednesdayHours;
			break;
		case Thursday:
			hoursStr = self.thursdayHours;
			break;
		case Friday:
			hoursStr = self.fridayHours;
			break;
		case Saturday:
			hoursStr = self.saturdayHours;
			break;
			
		default:
			break;
	}
	
	NSArray *hoursArray = [self parseHoursFromString:hoursStr];
	
	NSDate* hours = [hoursArray objectAtIndex:0];
	
	BOOL isOpen = NO;
	
	if ([hoursArray count] == 4) {
		isOpen = [self fourHours:hoursArray];
	} else if ([hoursArray count] == 2) {
		isOpen = [self twoHours:hoursArray];
	}

	return isOpen;
}

-(BOOL)fourHours:(NSArray*)hours
{
	NSDate* now = [[NSDate alloc] init];
	BOOL isOpen = NO;
	
	if ([now compare:[hours objectAtIndex:0]] == NSOrderedSame || [now compare:[hours objectAtIndex:0]] == NSOrderedDescending) {
		if ([now compare:[hours objectAtIndex:1]] == NSOrderedAscending) {
			isOpen = YES;
		}
	} else if ([now compare:[hours objectAtIndex:2]] == NSOrderedSame || [now compare:[hours objectAtIndex:2]] == NSOrderedDescending) {
		if ([now compare:[hours objectAtIndex:3]] == NSOrderedAscending) {
			isOpen = YES;
		}
	} 
	
	return isOpen;
}

-(BOOL)twoHours:(NSArray*)hours
{
	NSDate* now = [[NSDate alloc] init];
	BOOL isOpen = NO;
	if ([now compare:[hours objectAtIndex:0]] == NSOrderedSame || [now compare:[hours objectAtIndex:0]] == NSOrderedDescending) {
		if ([now compare:[hours objectAtIndex:1]] == NSOrderedAscending) {
			isOpen = YES;
		}
	}
	
	return isOpen;
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

- (int)numFromDay:(NSString*)day
{
	int returnNum;
	
	if ([day isEqual: @"Sunday"]) {
		returnNum = 0;
	} else if ([day isEqual: @"Monday"]) {
		returnNum = 1;
	} else if ([day isEqual: @"Tuesday"]) {
		returnNum = 2;
	} else if ([day isEqual: @"Wednesday"]) {
		returnNum = 3;
	} else if ([day isEqual: @"Thursday"]) {
		returnNum = 4;
	} else if ([day isEqual: @"Friday"]) {
		returnNum = 5;
	} else if ([day isEqual: @"Saturday"]) {
		returnNum = 6;
	} else {
		returnNum = -1;
	}
	
	return returnNum;
}

@end
