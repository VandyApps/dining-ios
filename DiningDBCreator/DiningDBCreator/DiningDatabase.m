//
//  DiningDatabase.m
//  DiningDBCreator
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "DiningDatabase.h"
#import "DLocation.h"

@implementation DiningDatabase

static DiningDatabase *_database;

+ (DiningDatabase *)database {
    if (_database == nil) {
        _database = [[DiningDatabase alloc] init];
    }
    return _database;
}

- (id)init {
    if ((self = [super init])) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"diningDBComplete"
                                                             ofType:@"sqlite3"];
        
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

@end
