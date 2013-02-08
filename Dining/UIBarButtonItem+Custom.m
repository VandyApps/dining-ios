//
//  UIBarButtonItem+Custom.m
//  Dining
//
//  Created by Scott Andrus on 2/7/13.
//  Copyright (c) 2013 VandyMobile. All rights reserved.
//

#import "UIBarButtonItem+Custom.h"

@implementation UIBarButtonItem (Custom)

//http://ashfurrow.com/blog/exploring-uibarbuttonitem
+ (id)barButtonWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, MAX(44, image.size.width), 44);
    button.contentMode = UIViewContentModeCenter;
    [button setShowsTouchWhenHighlighted:YES];
    
    [button setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return barButtonItem;
}

@end
