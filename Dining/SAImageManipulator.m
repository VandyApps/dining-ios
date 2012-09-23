//
//  SAImageManipulator.m
//
//  Created by Scott Andrus on 8/9/12.
//  Copyright (c) 2012 Tapatory, LLC. All rights reserved.
//

#import "SAImageManipulator.h"
#import "OBGradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SAImageManipulator

+ (UIView *)getPrimaryBackgroundGradientViewForView:(UIView *)view withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot {
    
    if (!gradientBot) {
        gradientBot = [UIColor colorWithRed:0.071 green:0.071 blue:0.071 alpha:1] /*#121212*/;
    }
    
    if (!gradientTop) {
        gradientTop = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:1] /*#3b3b3b*/;
    }
    
	NSArray *gradientColors = [NSArray arrayWithObjects:gradientTop, gradientBot, nil];
	
	OBGradientView *gradientView = [[OBGradientView alloc] init];
	[gradientView setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
	[gradientView setAutoresizingMask:view.autoresizingMask];
	[gradientView setColors:gradientColors];
	
	return gradientView;
}

+ (UIImage *)screenShotOfView:(UIView *)view {
    // Screenshot of the frame
    view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(view.layer.frame.size, view.opaque, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    return viewImage;
}

+ (UIImage *)gradientBackgroundImageForView:(UIView *)view withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot {
    return [SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]];
}

+ (CALayer *)getPrimaryBackgroundGradientViewForLayer:(CALayer *)layer withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot {
    
    if (!gradientBot) {
        gradientBot = [UIColor colorWithRed:0.071 green:0.071 blue:0.071 alpha:1] /*#121212*/;
    }
    
    if (!gradientTop) {
        gradientTop = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:1] /*#3b3b3b*/;
    }
    
	NSArray *gradientColors = [NSArray arrayWithObjects:gradientTop, gradientBot, nil];
	
	OBGradientView *gradientView = [[OBGradientView alloc] init];
	[gradientView setFrame:CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height)];
    UIView *view = [[UIView alloc] initWithFrame:layer.frame];
    [view.layer addSublayer:layer];
	[gradientView setAutoresizingMask:view.autoresizingMask];
	[gradientView setColors:gradientColors];
	
	return gradientView.layer;
}

+ (UIImage *)screenShotOfLayer:(CALayer *)layer {
    // Screenshot of the frame
    UIGraphicsBeginImageContext(layer.frame.size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    return viewImage;
}

+ (UIImage *)gradientBackgroundImageForLayer:(CALayer *)layer withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot {
    return [SAImageManipulator screenShotOfLayer:[SAImageManipulator getPrimaryBackgroundGradientViewForLayer:layer withTopColor:gradientTop andBottomColor:gradientBot]];
}

+ (void)setGradientBackgroundImageForView:(id)view withTopColor:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBot {
    if ([view respondsToSelector:@selector(setBackgroundImage:)]) {
        [view setBackgroundImage:[SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]]];
    } else if ([view respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [view setBackgroundImage:[SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    } else if ([view respondsToSelector:@selector(setBackgroundImage:forState:barMetrics:)]) {
        [view setBackgroundImage:[SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    } else if ([view respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [view setBackgroundImage:[SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]] forBarMetrics:UIBarMetricsDefault];
    } else if ([view respondsToSelector:@selector(setBackgroundImage:forState:)]) {
        [view setBackgroundImage:[SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]] forState:UIControlStateNormal];
    } else if ([view respondsToSelector:@selector(setImage:forState:)]) {
        [view setImage:[SAImageManipulator screenShotOfView:[SAImageManipulator getPrimaryBackgroundGradientViewForView:view withTopColor:gradientTop andBottomColor:gradientBot]] forState:UIControlStateNormal];
    } else {
        [view insertSubview:[[UIImageView alloc] initWithImage:[SAImageManipulator gradientBackgroundImageForView:view withTopColor:gradientTop andBottomColor:gradientBot]] atIndex:0];
    }
}

+ (void)addShadowToView:(UIView *)view withOpacity:(CGFloat)opacity radius:(CGFloat)radius andOffset:(CGSize)offset {
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    if (opacity) {
        if (opacity > 1) opacity = 1;
        else if (opacity < 0) opacity = 0;
        view.layer.shadowOpacity = opacity;
    }
    if (radius) view.layer.shadowRadius = 2.0;
    if (offset.height && offset.width) view.layer.shadowOffset = CGSizeMake(-1, 1);
}

+ (void)addBorderToView:(UIView *)view withWidth:(CGFloat)borderWidth color:(UIColor *)borderColor andRadius:(CGFloat)cornerRadius {
    if (borderWidth) view.layer.borderWidth = borderWidth;
    if (borderColor) view.layer.borderColor = [borderColor CGColor];
    if (cornerRadius) view.layer.cornerRadius = cornerRadius;
}

+ (void)roundNavigationBar:(UINavigationBar *)navigationBar {
    UIView *roundView = [navigationBar.subviews objectAtIndex:0];
    
    CALayer *capa = roundView.layer;

    //Round
    CGRect bounds = capa.bounds;
    bounds.size.height += 10.0f;    //I'm reserving enough room for the shadow
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;

    [capa addSublayer:maskLayer];
    capa.mask = maskLayer;
}

@end
