//
//  JSSlidingViewController.m
//  JSSlidingViewControllerSample
//
//  Created by Jared Sinclair on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSSlidingViewController.h"

NSString * const JSSlidingViewControllerWillOpenNotification = @"JSSlidingViewControllerWillOpenNotification";
NSString * const JSSlidingViewControllerWillCloseNotification = @"JSSlidingViewControllerWillCloseNotification";
NSString * const JSSlidingViewControllerDidOpenNotification = @"JSSlidingViewControllerDidOpenNotification";
NSString * const JSSlidingViewControllerDidCloseNotification = @"JSSlidingViewControllerDidCloseNotification";
NSString * const JSSlidingViewControllerWillBeginDraggingNotification = @"JSSlidingViewControllerWillBeginDraggingNotification";

@interface SlidingScrollView : UIScrollView

@end

@implementation SlidingScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO; // So that dropshadow along the sides of the frontViewController still appear when the slider is open.
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.scrollsToTop = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = YES;
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES; // Makes it so you can swipe to close the slider.
}

@end

@interface JSSlidingViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) SlidingScrollView *slidingScrollView;
@property (nonatomic, strong) UIButton *invisibleCloseSliderButton;
@property (nonatomic, assign) CGFloat sliderOpeningWidth;
@property (assign, nonatomic) CGFloat desiredVisiblePortionOfFrontViewWhenOpen;
@property (strong, nonatomic) UIImageView *frontViewControllerDropShadow;
@property (strong, nonatomic) UIImageView *frontViewControllerDropShadow_right;
@property (assign, nonatomic) BOOL isAnimatingInterfaceOrientation;

- (void)setupSlidingScrollView;
- (void)addInvisibleButton;

@end

@implementation JSSlidingViewController

@synthesize animating = _animating;
@synthesize isOpen = _isOpen;
@synthesize locked = _locked;
@synthesize frontViewControllerHasOpenCloseNavigationBarButton = _frontViewControllerHasOpenCloseNavigationBarButton;
@synthesize frontViewController = _frontViewController;
@synthesize backViewController = _backViewController;
@synthesize slidingScrollView = _slidingScrollView;
@synthesize invisibleCloseSliderButton = _invisibleCloseSliderButton;
@synthesize delegate;
@synthesize sliderOpeningWidth = _sliderOpeningWidth;
@synthesize allowManualSliding = _allowManualSliding;

#define kDefaultVisiblePortion 58.0f

#pragma mark - View Lifecycle

- (id)initWithFrontViewController:(UIViewController *)frontVC backViewController:(UIViewController *)backVC {
    NSAssert(frontVC, @"JSSlidingViewController requires both a front and a back view controller");
    NSAssert(backVC, @"JSSlidingViewController requires both a front and a back view controller");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _frontViewController = frontVC;
        _backViewController = backVC;
        _useBouncyAnimations = YES;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSlidingScrollView];
    CGRect frame = self.view.bounds;
    
    self.backViewController.view.frame = frame;
    [self addChildViewController:self.backViewController];
    [self.view insertSubview:self.backViewController.view atIndex:0];
    [self.backViewController didMoveToParentViewController:self];
    
    self.frontViewController.view.frame = CGRectMake(_sliderOpeningWidth, frame.origin.y, frame.size.width, frame.size.height);
    [self addChildViewController:self.frontViewController];
    [_slidingScrollView addSubview:self.frontViewController.view];
    [self.frontViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInterface];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateInterface];
}

#pragma mark - AutoRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL shouldAutorotate = NO;
    if ([self.delegate respondsToSelector:@selector(slidingViewController:shouldAutorotateToInterfaceOrientation:)]) {
        shouldAutorotate = [self.delegate slidingViewController:self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            shouldAutorotate = (interfaceOrientation == UIInterfaceOrientationPortrait);
        } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            shouldAutorotate = YES;
        }
    }
    return shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger interfaceOrientations = 0;
    if ([self.delegate respondsToSelector:@selector(supportedInterfaceOrientationsForSlidingViewController:)]) {
        interfaceOrientations = [self.delegate supportedInterfaceOrientationsForSlidingViewController:self];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            interfaceOrientations = UIInterfaceOrientationMaskPortrait;
        } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            interfaceOrientations = UIInterfaceOrientationMaskAll;
        }
    }
    return interfaceOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.isAnimatingInterfaceOrientation = YES;
    __weak JSSlidingViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        weakSelf.isAnimatingInterfaceOrientation = NO;
    });
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateInterface];
}

- (void)updateInterface {
    _sliderOpeningWidth = self.view.bounds.size.width - self.desiredVisiblePortionOfFrontViewWhenOpen;
    CGRect frame = self.view.bounds;
    CGFloat targetOriginForSlidingScrollView = 0;
    if (self.isOpen) {
        targetOriginForSlidingScrollView = _sliderOpeningWidth;
    }
    self.slidingScrollView.contentSize = CGSizeMake(frame.size.width + _sliderOpeningWidth, frame.size.height);
    self.frontViewControllerDropShadow.frame = CGRectMake(_sliderOpeningWidth - 20.0f, 0.0f, 20.0f, frame.size.height);
    self.frontViewControllerDropShadow_right.frame = CGRectMake(_sliderOpeningWidth + frame.size.width, 0.0f, 20.0f, frame.size.height);
    _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
    _slidingScrollView.frame = CGRectMake(targetOriginForSlidingScrollView, 0, frame.size.width, frame.size.height);
    self.frontViewController.view.frame = CGRectMake(_sliderOpeningWidth, 0, frame.size.width, frame.size.height);
    self.invisibleCloseSliderButton.frame = CGRectMake(_sliderOpeningWidth, self.invisibleCloseSliderButton.frame.origin.y, frame.size.width, frame.size.height);
}

#pragma mark - Status Bar Changes

- (void)statusBarFrameWillChange:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    CGRect statusbarframe = CGRectZero;
    NSValue *rectValue = [dictionary valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    [rectValue getValue:&statusbarframe];
    CGRect mainbounds = [[UIScreen mainScreen] bounds];
    CGFloat targetHeight = mainbounds.size.height-statusbarframe.size.height;
    [UIView animateWithDuration:0.25f animations:^{
        self.slidingScrollView.contentSize = CGSizeMake(self.slidingScrollView.contentSize.width, targetHeight);
        CGRect shadowFrame = self.frontViewControllerDropShadow.frame;
        shadowFrame.size.height = targetHeight;
        self.frontViewControllerDropShadow.frame = shadowFrame;
        shadowFrame = self.frontViewControllerDropShadow_right.frame;
        shadowFrame.size.height = targetHeight;
        self.frontViewControllerDropShadow_right.frame = shadowFrame;
    }];
}

#pragma mark - Controlling the Slider

- (void)closeSlider:(BOOL)animated completion:(void (^)(void))completion {
    [completion copy];
    if (_animating == NO && _isOpen && _locked == NO) {
        [self willClose];
        _isOpen = NO; // Needs to be here to prevent bugs
        _animating = YES;
        if (self.useBouncyAnimations) {
            [self closeWithBouncyAnimation:animated completion:completion];
        } else {
            [self closeWithSmoothAnimation:animated completion:completion];
        }
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)closeWithBouncyAnimation:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat duration1 = 0.0f;
    CGFloat duration2 = 0.0f;
    if (animated) {
        duration1 = 0.18f;
        duration2 = 0.1f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            duration1 = duration1 * 1.5f;
            duration2 = duration2 * 1.5f;
        }
    }
    [UIView animateWithDuration: duration1 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration animations:^{
        CGRect rect = _slidingScrollView.frame;
        rect.origin.x = -10.0f;
        _slidingScrollView.frame = rect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration: duration2 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration animations:^{
            CGRect rect = _slidingScrollView.frame;
            rect.origin.x = 0;
            _slidingScrollView.frame = rect;
        } completion:^(BOOL finished) {
            if (self.invisibleCloseSliderButton) {
                [self.invisibleCloseSliderButton removeFromSuperview];
                self.invisibleCloseSliderButton = nil;
            }
            _animating = NO;
            self.view.userInteractionEnabled = YES;
            [self didClose];
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)closeWithSmoothAnimation:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat duration = 0;
    if (animated) {
        duration = 0.25f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            duration = 0.4f;
        }
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration animations:^{
        CGRect rect = _slidingScrollView.frame;
        rect.origin.x = 0;
        _slidingScrollView.frame = rect;
    } completion:^(BOOL finished) {
        if (self.invisibleCloseSliderButton) {
            [self.invisibleCloseSliderButton removeFromSuperview];
            self.invisibleCloseSliderButton = nil;
        }
        _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
        _animating = NO;
        self.view.userInteractionEnabled = YES;
        [self didClose];
        if (completion) {
            completion();
        }
    }];
}

- (void)openSlider:(BOOL)animated completion:(void (^)(void))completion {
    [completion copy];
    if (_animating == NO && _isOpen == NO && _locked == NO) {
        [self willOpen];
        _animating = YES;
        _isOpen = YES; // Needs to be here to prevent bugs
        if (self.useBouncyAnimations) {
            [self openWithBouncyAnimation:animated completion:completion];
        } else {
            [self openWithSmoothAnimation:animated completion:completion];
        }
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)openWithBouncyAnimation:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat duration1 = 0.0f;
    CGFloat duration2 = 0.0f;
    if (animated) {
        duration1 = 0.18f;
        duration2 = 0.18f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            duration1 = duration1 * 1.5f;
            duration2 = duration2 * 1.5f;
        }
    }
    [UIView animateWithDuration:duration1  delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration  animations:^{
        CGRect aRect = _slidingScrollView.frame;
        aRect.origin.x = _sliderOpeningWidth + 10;
        _slidingScrollView.frame = aRect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration2  delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration animations:^{
            CGRect rect = _slidingScrollView.frame;
            rect.origin.x = _sliderOpeningWidth;
            _slidingScrollView.frame = rect;
        } completion:^(BOOL finished) {
            if (self.invisibleCloseSliderButton == nil) {
                [self addInvisibleButton];
            }
            _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
            _animating = NO;
            self.view.userInteractionEnabled = YES;
            [self didOpen];
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)openWithSmoothAnimation:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.25f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            duration = 0.4f;
        }
    }
    [UIView animateWithDuration:duration  delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration animations:^{
        CGRect rect = _slidingScrollView.frame;
        rect.origin.x = _sliderOpeningWidth;
        _slidingScrollView.frame = rect;
    } completion:^(BOOL finished) {
        if (self.invisibleCloseSliderButton == nil) {
            [self addInvisibleButton];
        }
        _animating = NO;
        self.view.userInteractionEnabled = YES;
        [self didOpen];
        if (completion) {
            completion();
        }
        
    }];
}

- (void)setFrontViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    NSAssert(viewController, @"JSSlidingViewController requires both a front and a back view controller");
    UIViewController *newFrontViewController = viewController;
    CGRect frame = self.view.bounds;
    newFrontViewController.view.frame = CGRectMake(_sliderOpeningWidth, frame.origin.y, frame.size.width, frame.size.height);
    newFrontViewController.view.alpha = 0.0f;
    [self addChildViewController:newFrontViewController];
    [_slidingScrollView addSubview:newFrontViewController.view];
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.25f;
    }
    [UIView animateWithDuration:duration animations:^{
        newFrontViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [_frontViewController willMoveToParentViewController:nil];
        [_frontViewController.view removeFromSuperview];
        [_frontViewController removeFromParentViewController];
        [newFrontViewController didMoveToParentViewController:self];
        _frontViewController = newFrontViewController;
    }];
}

- (void)setBackViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    NSAssert(viewController, @"JSSlidingViewController requires both a front and a back view controller");
    UIViewController *newBackViewController = viewController;
    newBackViewController.view.frame = self.view.bounds;
    [self addChildViewController:newBackViewController];
    [self.view insertSubview:newBackViewController.view atIndex:0];
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.25f;
    }
    [UIView animateWithDuration:duration animations:^{
        _backViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_backViewController willMoveToParentViewController:nil];
        [_backViewController.view removeFromSuperview];
        [_backViewController removeFromParentViewController];
        [newBackViewController didMoveToParentViewController:self];
        _backViewController = newBackViewController;
    }];
}

#pragma mark - Scroll View Delegate for the Sliding Scroll View

/*
 
 SLIDING SCROLL VIEW DISCUSSION
 
 Nota Bene:
 Some of these scroll view delegate method implementations may look quite strange, but
 it has to do with the peculiarities of the timing and circumstances of UIScrollViewDelegate
 callbacks. Numerous bugs and unusual edge cases have been accounted for via rigorous testing.
 Edit these with extreme care!!!
 
 How It Works:
 
 1. The slidingScrollView is a container for the frontmost content. The backmost content is not a part of the slidingScrollView's hierarchy.
 The slidingScrollView has a clear background color, which masks the technique I'm using. To make it easier to see what's happening,
 try temporarily setting it's background color to a semi-translucent color in the -(void)setupSlidingScrollView method.
 
 2. When the slider is closed and at rest, the scroll view's frame fills the display.
 
 3. When the slider is open and at rest, the scroll view's frame is snapped over to the right,
 starting at an x origin of 262.
 
 4. When the slider is being opened or closed and is tracking a dragging touch, the scroll view's frame fills
 the display.
 
 5a. When the slider has finished animating/decelerating to either the closed or open position, the
 UIScrollView delegate callbacks are used to determine what to do next.
 5b. If the slider has come to rest in the open position, the scroll view's frame's x origin is set to the value
 in #3, and an "invisible button" is added over the visible portion of the main content
 to catch touch events and trigger a close action.
 5c. If the slider has come to rest in the closed position, the invisible button is removed, and the
 scroll view's frame once again fills the display.
 
 6. Numerous edge cases were solved for, most of them related to what happens when touches/drags
 begin or end before the slider has finished decelerating (in either direction).
 
 7a. Changes to the scroll view frame or the invisible button are also triggered by UIView touch event
 methods like touchesBegan and touchesEnded.
 7b. Since not every touch sequence turns into a drag, responses to these touch events must perform
 some of the same functions as responses to scroll view delegate methods. This explains why there is
 some overlap between the two kinds of sequences.
 
 Summary:
 
 By combining UIScrollViewDelegate methods and UIView touch event methods, I am able to mimic the slide-to-reveal
 navigation that is currently in-vogue, but without having to manually track touches and calculate dragging & decelerating
 animations. Apple's own implementation of UIScrollView touch tracking is infinitely smoother and richer than any
 third party library.
 
 */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // BIG NASTY BUG IN iOS 6.x -- December 1, 2012 ~ JTS.
    // Under certain conditions, when nesting a table view inside of a scroll view,
    // as is frequently the case when using JSSlidingViewController,
    // scrollViewDidScroll: can be called from the outermost scrollView without scrollViewWillBeginDragging:
    // ever being called on that scrollView's delegate. Without knowing the internals of UIScrollView's implementation, the
    // best assumption we have is that the outer most scroll view (in our case the JSSlidingViewController's
    // slidingScrollView) does not "know" that it's scrolling (dragging/tracking methods aren't triggered
    // properly).
    
    // What the Bug Looks Like ---
    // When scrolling a table view inside the slidingScrollView, the slider may pop open and closed about 1 to 20 pixels
    // while scrolling, but never fully opening all the way. It's unusual to say the least. It's very difficult to reproduce
    // if your table view controller is inside a UINavigationController with a visible nav bar. Hiding the navigation bar
    // seems to make the issue more prominent.
    
    // How to Reproduce the Bug ---
    // 1) Nest a table view inside the slidingScrollView (it's okay if this tableview is inside of a UINavigationController).
    // 2) Present a full-screen modal view controller while the slider is closed.
    // 3) Dismiss the modal view controller
    // 4) Begin scrolling again on the tableview, quickly, in a semi-diagonal swipe direction
    //    that is 90 percent vertical.
    // 5) Observe the left hand edge of the screen for the jittery open/close while scrolling.
    
    // It's hard to reproduce, but trust me, it's there. I will follow up with Apple with a radar.
    
    // The following code doesn't "fix" the bug per se, but it will at least
    // make sure that the back view controller is visible if the back view controller's view is
    // set to be removed from the hierarchy when the slider is closed.
    
    // Note: December 9, 2012
    // We need to disable this bug correction during autorotation, since scrollViewDidScroll
    // is called as the slidingScrollView updates it's layout for a new interfaceOrientation. ~ JTS.
    
    if (self.isOpen == NO && self.isAnimatingInterfaceOrientation == NO) {
        CGPoint co = scrollView.contentOffset;
        if (co.x != self.sliderOpeningWidth) {
            [self scrollViewWillBeginDragging:scrollView];
            [self willOpen];
            _isOpen = YES;
            [self didOpen];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_animating == NO) {
        if (decelerate == YES) {
            // We'll handle the rest after it's done decelerating...
            self.view.userInteractionEnabled = NO;
        } else {
            CGPoint origin = self.frontViewController.view.frame.origin;
            origin = [_slidingScrollView convertPoint:origin toView:self.view];
            if (origin.x >= _sliderOpeningWidth) {
                if (self.invisibleCloseSliderButton == nil) {
                    [self addInvisibleButton];
                }
                CGRect rect = _slidingScrollView.frame;
                rect.origin.x = _sliderOpeningWidth;
                _slidingScrollView.frame = rect;
                _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
                _isOpen = YES;
            } else {
                if (self.invisibleCloseSliderButton) {
                    [self.invisibleCloseSliderButton removeFromSuperview];
                    self.invisibleCloseSliderButton = nil;
                }
                [self willClose];
                _isOpen = NO;
                [self didClose];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_animating == NO) {
        CGPoint origin = self.frontViewController.view.frame.origin;
        origin = [_slidingScrollView convertPoint:origin toView:self.view];
        if ( (origin.x >= _sliderOpeningWidth) && (scrollView.dragging == NO) ){
            if (self.invisibleCloseSliderButton == nil) {
                [self addInvisibleButton];
            }
            CGRect rect = _slidingScrollView.frame;
            rect.origin.x = _sliderOpeningWidth;
            _slidingScrollView.frame = rect;
            _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
            _isOpen = YES;
        } else {
            if (self.invisibleCloseSliderButton) {
                [self.invisibleCloseSliderButton removeFromSuperview];
                self.invisibleCloseSliderButton = nil;
            }
            [self willClose];
            _isOpen = NO;
            [self didClose];
        }
        self.view.userInteractionEnabled = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isOpen == YES && _locked == NO) {
        CGRect rect = _slidingScrollView.frame;
        rect.origin.x = 0;
        _slidingScrollView.frame = rect;
        _slidingScrollView.contentOffset = CGPointMake(0, 0);
        if (self.invisibleCloseSliderButton) {
            [self.invisibleCloseSliderButton removeFromSuperview];
            self.invisibleCloseSliderButton = nil;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:JSSlidingViewControllerWillBeginDraggingNotification object:self]];
    
    if (_locked == NO) {
        if (_isOpen == YES) {
            CGRect rect = _slidingScrollView.frame;
            rect.origin.x = 0;
            _slidingScrollView.frame = rect;
            _slidingScrollView.contentOffset = CGPointMake(0, 0);
            if (self.invisibleCloseSliderButton) {
                [self.invisibleCloseSliderButton removeFromSuperview];
                self.invisibleCloseSliderButton = nil;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isOpen == YES && _locked == NO) {
        if (self.invisibleCloseSliderButton == nil) {
            [self addInvisibleButton];
        }
        CGRect rect = _slidingScrollView.frame;
        rect.origin.x = _sliderOpeningWidth;
        _slidingScrollView.frame = rect;
        _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
    }
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Setup

- (void)setupSlidingScrollView {
    CGRect frame = self.view.bounds;
    [self setWidthOfVisiblePortionOfFrontViewControllerWhenSliderIsOpen:kDefaultVisiblePortion];
    self.slidingScrollView = [[SlidingScrollView alloc] initWithFrame:frame];
    _slidingScrollView.contentOffset = CGPointMake(_sliderOpeningWidth, 0);
    _slidingScrollView.contentSize = CGSizeMake(frame.size.width + _sliderOpeningWidth, frame.size.height);
    _slidingScrollView.delegate = self;
    [self.view insertSubview:_slidingScrollView atIndex:0];
    _isOpen = NO;
    _locked = NO;
    _animating = NO;
    _frontViewControllerHasOpenCloseNavigationBarButton = YES;
    _allowManualSliding = YES;
    
    self.frontViewControllerDropShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frontViewControllerDropShadow.png"]];
    self.frontViewControllerDropShadow.frame = CGRectMake(_sliderOpeningWidth - 20.0f, 0.0f, 20.0f, _slidingScrollView.bounds.size.height);
    [_slidingScrollView addSubview:self.frontViewControllerDropShadow];
    
    self.frontViewControllerDropShadow_right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frontViewControllerDropShadow.png"]];
    self.frontViewControllerDropShadow_right.frame = CGRectMake(_sliderOpeningWidth + frame.size.width, 0.0f, 20.0f, _slidingScrollView.bounds.size.height);
    self.frontViewControllerDropShadow_right.transform = CGAffineTransformMakeRotation(M_PI);
    [_slidingScrollView addSubview:self.frontViewControllerDropShadow_right];
}

#pragma mark - Convenience

- (void)setFrontViewControllerHasOpenCloseNavigationBarButton:(BOOL)frontViewControllerHasOpenCloseNavigationBarButton {
    if (_frontViewControllerHasOpenCloseNavigationBarButton != frontViewControllerHasOpenCloseNavigationBarButton) {
        _frontViewControllerHasOpenCloseNavigationBarButton = frontViewControllerHasOpenCloseNavigationBarButton;
        if (self.invisibleCloseSliderButton.superview) {
            [self removeInvisibleButton];
            [self addInvisibleButton];
        }
    }
}

- (void)addInvisibleButton {
    self.invisibleCloseSliderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.invisibleCloseSliderButton.showsTouchWhenHighlighted = NO;
    CGFloat yOrigin = 0.0f;
    if (_frontViewControllerHasOpenCloseNavigationBarButton) {
        yOrigin = 44.0f;
    }
    self.invisibleCloseSliderButton.frame = CGRectMake(self.frontViewController.view.frame.origin.x, yOrigin, self.view.frame.size.width, self.view.frame.size.height - yOrigin);
    self.invisibleCloseSliderButton.backgroundColor = [UIColor clearColor];
    self.invisibleCloseSliderButton.accessibilityElementsHidden = YES;
    [self.invisibleCloseSliderButton addTarget:self action:@selector(invisibleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_slidingScrollView addSubview:self.invisibleCloseSliderButton];
}

- (void)removeInvisibleButton {
    [self.invisibleCloseSliderButton removeFromSuperview];
    self.invisibleCloseSliderButton = nil;
}

- (void)invisibleButtonPressed {
    if (_locked == NO) {
        [self closeSlider:YES completion:nil];
    }
}

- (void)setWidthOfVisiblePortionOfFrontViewControllerWhenSliderIsOpen:(CGFloat)width {
    CGFloat startingVisibleWidth = _sliderOpeningWidth;
    self.desiredVisiblePortionOfFrontViewWhenOpen = width;
    _sliderOpeningWidth = self.view.bounds.size.width - self.desiredVisiblePortionOfFrontViewWhenOpen;
    if (startingVisibleWidth != _sliderOpeningWidth) {
        [self updateInterface];
    }
}

- (void)setLocked:(BOOL)locked {
    _locked = locked;
    if (_allowManualSliding && locked == NO) {
        _slidingScrollView.scrollEnabled = YES;
    } else {
        _slidingScrollView.scrollEnabled = NO;
    }
}

- (void)setAllowManualSliding:(BOOL)allowManualSliding {
    _allowManualSliding = allowManualSliding;
    _slidingScrollView.scrollEnabled = allowManualSliding;
}

- (UIViewController *)frontViewController {
    return _frontViewController;
}

- (UIViewController *)backViewController {
    return _backViewController;
}

- (BOOL)locked {
    return _locked;
}

- (BOOL)animating {
    return _animating;
}

- (BOOL)isOpen {
    return _isOpen;
}

- (void)printFrame:(CGRect)frame {
    NSLog(@"Frame: %g %g %g %g", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

#pragma mark - Add/Remove Back View if Appropriate

- (void)willOpen {
    if (self.shouldTemporarilyRemoveBackViewControllerWhenClosed) {
        [self.view insertSubview:self.backViewController.view atIndex:0];
    }
    if ([self.delegate respondsToSelector:@selector(slidingViewControllerWillOpen:)]) {
        [self.delegate slidingViewControllerWillOpen:self];
    }
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:JSSlidingViewControllerWillOpenNotification object:self]];
}

- (void)didOpen {
    if ([self.delegate respondsToSelector:@selector(slidingViewControllerDidOpen:)]) {
        [self.delegate slidingViewControllerDidOpen:self];
    }
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:JSSlidingViewControllerDidOpenNotification object:self]];
}

- (void)willClose {
    if ([self.delegate respondsToSelector:@selector(slidingViewControllerWillClose:)]) {
        [self.delegate slidingViewControllerWillClose:self];
    }
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:JSSlidingViewControllerWillCloseNotification object:self]];
}

- (void)didClose {
    if (self.shouldTemporarilyRemoveBackViewControllerWhenClosed) {
        [self.backViewController.view removeFromSuperview];
    }
    if ([self.delegate respondsToSelector:@selector(slidingViewControllerDidClose:)]) {
        [self.delegate slidingViewControllerDidClose:self];
    }
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:JSSlidingViewControllerDidCloseNotification object:self]];
}

#pragma mark - Accessiblility

- (BOOL)accessibilityPerformEscape {
    [self closeSlider:YES completion:nil];
    return YES;
}

@end








