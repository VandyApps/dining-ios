//
//  DLocation.h
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DLocation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * sundayHours;
@property (nonatomic, retain) NSString * mondayHours;
@property (nonatomic, retain) NSString * tuesdayHours;
@property (nonatomic, retain) NSString * wednesdayHours;
@property (nonatomic, retain) NSString * thursdayHours;
@property (nonatomic, retain) NSString * fridayHours;
@property (nonatomic, retain) NSString * saturdayHours;
@property (nonatomic, retain) NSString * detailDescription;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * isMealMoney;
@property (nonatomic, retain) NSNumber * isMealPlan;
@property (nonatomic, retain) NSNumber * isOnCampus;
@property (nonatomic, retain) NSNumber * locID;

// Non core data properties
@property (nonatomic, strong) NSNumber * distance;

-(BOOL)isOpen;

@end
