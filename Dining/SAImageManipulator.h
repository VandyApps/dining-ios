//
//  SAImageManipulator.h
//
//  Created by Scott Andrus on 8/9/12.
//  Copyright (c) 2012 Tapatory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAImageManipulator : NSObject

+ (UIView *)getPrimaryBackgroundGradientViewForView:(UIView *)view withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot;

+ (UIImage *)screenShotOfView:(UIView *)view;

+ (UIImage *)gradientBackgroundImageForView:(UIView *)view withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot;

+ (void)setGradientBackgroundImageForView:(id)view withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot;

+ (void)addShadowToView:(UIView *)view withOpacity:(CGFloat)opacity radius:(CGFloat)radius andOffset:(CGSize)offset;

+ (void)addBorderToView:(UIView *)view withWidth:(CGFloat)borderWidth color:(UIColor *)borderColor andRadius:(CGFloat)cornerRadius;

+ (void)roundNavigationBar:(UINavigationBar *)navigationBar;

@end
