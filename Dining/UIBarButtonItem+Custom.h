//
//  UIBarButtonItem+Custom.h
//  Dining
//
//  Created by Scott Andrus on 2/7/13.
//  Copyright (c) 2013 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Custom)

+ (id)barButtonWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;

@end
