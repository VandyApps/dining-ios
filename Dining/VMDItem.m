//
//  VMDItem.m
//  Dining
//
//  Created by Oliver Dormody on 11/1/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDItem.h"

@implementation VMDItem

- (id)initWithName:(NSString *)name category:(NSString *)category nutrition:(NSDictionary *)nutrition
{
    self = [super init];
    if (self) {
        self.name = name;
        self.category = category;
        self.nutrition = nutrition;
    }
    return self;
}

@end
