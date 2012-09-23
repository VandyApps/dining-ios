//
//  VMDLocationDetailVC.m
//  Dining
//
//  Created by Scott Andrus on 9/22/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDLocationDetailVC.h"
#import "UIView+Frame.h"

#import <QuartzCore/QuartzCore.h>

@interface VMDLocationDetailVC ()

@end

@implementation VMDLocationDetailVC

@synthesize location = _location;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self customizeUI];
    [self downloadPhoto];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameLabel:nil];
    [self setCoverImageView:nil];
    [self setDateScrollView:nil];
    [self setDayLabel:nil];
    [self setDateLabel:nil];
    [self setHoursLabel:nil];
    [self setTitleOverlayImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Utility methods

- (void)customizeUI {
    
    self.nameLabel.text = self.location.name;
    self.nameLabel.size = [self.nameLabel.text sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(200, self.nameLabel.height)];

    self.titleOverlayImageView.image = [[UIImage imageNamed:@"blackoverlay.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    if (self.nameLabel.width > 111) {
        self.titleOverlayImageView.width = self.nameLabel.width + 11;
    } else {
        self.titleOverlayImageView.width = 123;
    }
    
    self.titleOverlayImageView.layer.cornerRadius = 5;
    
    self.dateScrollView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.dateScrollView.layer.borderWidth = .5;
    
    // Format photo imageview
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.coverImageView.layer.borderWidth = .5;
    
    [self setupDateScrollView];
}

- (void)setupDateScrollView {
    [self.dateScrollView setContentSize:CGSizeMake(self.dateScrollView.width * 7, self.dateScrollView.height)];
    
    UILabel *aDayLabel;
    UILabel *aDateLabel;
    UILabel *anHoursLabel;
    for (size_t i = 1; i < 7; ++i) {
        
        // Create day labels
        aDayLabel = [[UILabel alloc] init];
        [self.dateScrollView addSubview:aDayLabel];
        [aDayLabel setFrame:CGRectMake(self.dayLabel.left + self.dateScrollView.width * i, self.dayLabel.top, self.dayLabel.width, self.dayLabel.height)];
        aDayLabel.textColor = [UIColor darkGrayColor];
        aDayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        aDayLabel.backgroundColor = [UIColor clearColor];
        aDayLabel.textAlignment = UITextAlignmentCenter;
        aDayLabel.text = @"Weekday";
        
        // Create date labels
        aDateLabel = [[UILabel alloc] init];
        [self.dateScrollView addSubview:aDateLabel];
        [aDateLabel setFrame:CGRectMake(self.dateLabel.left + self.dateScrollView.width * i, self.dateLabel.top, self.dateLabel.width, self.dateLabel.height)];
        aDateLabel.textColor = [UIColor darkGrayColor];
        aDateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        aDateLabel.backgroundColor = [UIColor clearColor];
        aDateLabel.textAlignment = UITextAlignmentCenter;
        aDateLabel.text = @"Date 01, 1999";
        
        // Create hours labels
        anHoursLabel = [[UILabel alloc] init];
        [self.dateScrollView addSubview:anHoursLabel];
        [anHoursLabel setFrame:CGRectMake(self.hoursLabel.left + self.dateScrollView.width * i, self.hoursLabel.top, self.hoursLabel.width, self.hoursLabel.height)];
        anHoursLabel.textColor = [UIColor darkGrayColor];
        anHoursLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        anHoursLabel.backgroundColor = [UIColor clearColor];
        anHoursLabel.textAlignment = UITextAlignmentCenter;
        anHoursLabel.text = @"8 AM - 9 PM";
    }
}

- (void)downloadPhoto {
    // Download photo
    if (![self.location.name isEqualToString:@"Featheringill Hall"]) {
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loading startAnimating];
        UIBarButtonItem * temp = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loading];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("image donwloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://lh6.googleusercontent.com/-aqq7PmycegM/TrldNljr17I/AAAAAAAAAB4/i36AmfII0bI/s1024/4840887935_697d9067a0_b.jpg"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.coverImageView setImage:[UIImage imageWithData:imgUrl]];
                [loading stopAnimating];
                self.navigationItem.rightBarButtonItem = temp;
            });
        });
        dispatch_release(downloadQueue);
    }
    else {
        [self.coverImageView setImage:[UIImage imageNamed:@"Featheringill.jpeg"]];
    }
}

@end
