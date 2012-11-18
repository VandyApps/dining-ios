//
//  VMDItem.m
//  Dining
//
//  Created by Oliver Dormody on 11/1/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDItem.h"

@implementation VMDItem

- (id)initWithName:(NSString *)name category:(NSString *)category nutrition:(NSDictionary *)nutrition {
    self = [super init];
    if (self) {
        self.category = category;
        self.nutrition = nutrition;
        self.name = name;
    }
    return self;
}

@end
