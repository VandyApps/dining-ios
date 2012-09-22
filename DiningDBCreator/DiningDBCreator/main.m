//
//  main.m
//  DiningDBCreator
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <sqlite3.h>
#import "DLocation.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    
    NSString *path = @"Dining";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
        
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        sqlite3 *database;
        
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"diningDBComplete" ofType:@"db"];
        
        if (sqlite3_open([sqLiteDb UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        NSString *query = @"SELECT * FROM dining";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                DLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"DLocation" inManagedObjectContext:context];
                
                int uniqueId = sqlite3_column_int(statement, 0);
                location.locID = [NSNumber numberWithInt:uniqueId];
                bool isOnCampus = (bool) sqlite3_column_int(statement, 1);
                location.isOnCampus = [NSNumber numberWithBool:isOnCampus];
                bool isMealPlan = (bool) sqlite3_column_int(statement, 2);
                location.isMealPlan = [NSNumber numberWithBool:isMealPlan];
                bool isMealMoney = (bool) sqlite3_column_int(statement, 3);
                location.isMealMoney = [NSNumber numberWithBool:isMealMoney];
                
                location.phone = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                location.url = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                location.type = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
                
                bool isFavorite = sqlite3_column_int(statement, 7);
                location.isFavorite = [NSNumber numberWithBool:isFavorite];
                
                if (sqlite3_column_text(statement, 8)) {
                    location.detailDescription = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 8)];
                }
                
                location.saturdayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 9)];
                location.fridayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 10)];
                location.thursdayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 11)];
                location.wednesdayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 12)];
                location.tuesdayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 13)];
                location.mondayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 14)];
                location.sundayHours = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 15)];
                
                float latitudeFloat = sqlite3_column_double(statement, 16);
                location.latitude = [NSNumber numberWithFloat:latitudeFloat];
                float longitudeFloat = sqlite3_column_double(statement, 17);
                location.longitude = [NSNumber numberWithFloat:longitudeFloat];
                
                location.name = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 18)];
                NSError *newError;
                if (![context save:&newError]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                
            }
            sqlite3_finalize(statement);
        }
        
        
        // Test listing all FailedBankInfos from the store
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DLocation"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (DLocation *info in fetchedObjects) {
            NSLog(@"Name: %@", info.name);
        }

    }
    return 0;
}

