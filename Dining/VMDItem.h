//
//  VMDItem.h
//  Dining
//
//  Created by Oliver Dormody on 11/1/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMDItem : NSObject

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *nutrition;

@end
