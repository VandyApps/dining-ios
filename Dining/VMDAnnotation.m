//
//  VMDAnnotation.m
//  Dining
//
//  Created by Scott Andrus on 12/31/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDAnnotation.h"

@implementation VMDAnnotation

@synthesize image;
@synthesize latitude;
@synthesize longitude;

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle andCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        self.name = title;
        self.category = subtitle;
        self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
        self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

- (NSString *)title
{
    return self.name;
}

// optional
- (NSString *)subtitle
{
    return self.category;
}

@end
