//
//  VMDAppDelegate.h
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VMDTabBarController.h"
#import "JSSlidingViewController.h"
#import "VMDOptionsViewController.h"

@interface VMDAppDelegate : UIResponder <UIApplicationDelegate, JSSlidingViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) JSSlidingViewController *viewController;

@property (strong, nonatomic) VMDOptionsViewController *backVC;
@property (strong, nonatomic) VMDTabBarController *frontVC;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
