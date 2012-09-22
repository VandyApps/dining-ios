//
//  DiningDatabase.h
//  DiningDBCreator
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DiningDatabase : NSObject {
    sqlite3 *_database;
}

+ (DiningDatabase*)database;

@end
