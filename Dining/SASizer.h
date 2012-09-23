//
//  SASizer.h
//
//  Created by Scott Andrus on 6/16/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SASizer : NSObject

+ (CGRect)sizeTextView:(UITextView *)textView withMaxHeight:(CGFloat)maxHeight andFont:(UIFont *)font;
+ (CGFloat)sizeText:(NSString *)text withConstraint:(CGSize)constraintSize font:(UIFont *)font andMinimumHeight:(CGFloat)minHeight;

@end
