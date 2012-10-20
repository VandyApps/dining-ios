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

// Weekdays type
typedef enum weekdays
{
    Sunday = 1,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
} Weekday;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self customizeUI];
    [self downloadPhoto];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.dateScrollView setContentOffset:CGPointMake(self.dateScrollView.width * 3, 0) animated:YES];
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
    [self setTitleOverlayView:nil];
    [self setTypeLabel:nil];
    [self setDateLeftButton:nil];
    [self setDateRightButton:nil];
    [super viewDidUnload];
}

#pragma mark - Utility methods

// Customizes the UI, typically called on viewDidLoad
- (void)customizeUI {
    
    // Modify the name label
    self.nameLabel.text = self.location.name;
    self.nameLabel.size = [self.nameLabel.text sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(200, self.nameLabel.height)];
    
    // Width calculations based on Interface Builder dimensions
    if (self.nameLabel.width > 111) self.titleOverlayView.width = self.nameLabel.width + 15;
    else self.titleOverlayView.width = 125;
    
    // Add some borders and round some corners (QuartzCore)
    self.titleOverlayView.layer.cornerRadius = 10;
    self.dateScrollView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.dateScrollView.layer.borderWidth = .5;
    
    // Format photo imageview
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.coverImageView.layer.borderWidth = .5;
    
    // Set up the date scroll view
    [self setupDateScrollView];
}

/**
 * Generates a String array from a String containing a comma- and semicolon-separated list of times
 * @param _in: a String containing a list of open and close times (e.g. "10:00,14:00;17:30,23:30")
 * @return: a String array containing the time values split up (e.g. {"10:00","14:00","17:30","23:30"})
 */
- (NSArray *)parseHoursFromString:(NSString *)string {
    //    String[] ret = {null,null,null,null};
    
    if ([string isEqualToString:@"null"]) {
        return nil;
    }
    
    // Create a blank mutable array
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:4];
    
    for (int i = 0; i < [string length]; i++){
        
        
//        if (_in.charAt(i)== ','){
//            ret[0]= _in.substring(0, i);//once you reach the first comma, break off the first start hour into ret[0]
        
        // Once you reach the first comma, break off the first start hour into ret[0]
        if ([string characterAtIndex:i] == ',') {
            [ret setObject:[string substringToIndex:i] atIndexedSubscript:0];
            
//            for (int x = i; x < _in.length();x++){
//                if (_in.charAt(x) == ';'){//if you hit a semicolon, there are two start and end times today.
//                                          //Don't worry, we'll use recursion!
            
            // if you hit a semicolon, there are two start and end times today.
            // Don't worry, we'll use recursion!
            for (int x = i; x < [string length]; x++) {
                if ([string characterAtIndex:x] == ';') {
            
//                    ret[1] = _in.substring(i+1,x);
//                    String[] tmp2 = parseHours(_in.substring(x+1));
//                    ret[2] = tmp2[0]; ret[3] = tmp2[1];
//                    break;
                    [ret setObject:[string substringWithRange:NSRangeFromString([NSString stringWithFormat:@"%d+1, %d", i, x])] atIndexedSubscript:1];
                    
                    NSArray *tmp2 = [self parseHoursFromString:[string substringToIndex:(x + 1)]];
                    
                    [ret setObject:[tmp2 objectAtIndex:0] atIndexedSubscript:2];
                    [ret setObject:[tmp2 objectAtIndex:1] atIndexedSubscript:3];
                    
                    break;
        
                }
                // If you hit the end of the string and haven't found a semicolon, don't worry!
                // There are only one set of hours for today.
                else if (x == [string length] - 1) {
                    
//                    ret[1] = _in.substring(i+1);//grab the second hour string into ret[2] -
                                                //don't worry about ret[3] and ret[4], we'll check for null later
                    [ret setObject:[string substringFromIndex:(i + 1)] atIndexedSubscript:1];
                }
            }
            break;
        }
    }
    
    return [ret copy];
}

// Sets up the date scrollview for the current day of the week and date
- (void)setupDateScrollView {
    
    // Set the initial content size to be 7 times as wide for 7 days
    [self.dateScrollView setContentSize:CGSizeMake(self.dateScrollView.width * 7, self.dateScrollView.height)];
    
    // Grab the current date, convert it to weekday components
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSHourCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
    
    NSInteger weekday = [weekdayComponents weekday];
    
//    NSInteger hour = [weekdayComponents hour];
//    NSInteger day = [weekdayComponents day];
//    NSInteger month = [weekdayComponents month];
//    NSInteger year = [weekdayComponents year];
    
    // Format the date to a shortened mode
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yy"];
    
    // Create some label pointers to be used in creating the weekday labels
    UILabel *aDayLabel;
    UILabel *aDateLabel;
    UILabel *anHoursLabel;
    
    // From -3 (three days ago) to 3 (three days from now) 
    for (int i = -3; i < 4; ++i) {
        
        // Create day label
        aDayLabel = [[UILabel alloc] init];
        [self.dateScrollView addSubview:aDayLabel];
        
        // Set the frame of the day label to i + 3
        [aDayLabel setFrame:CGRectMake(self.dayLabel.left + self.dateScrollView.width * (i + 3), self.dayLabel.top, self.dayLabel.width, self.dayLabel.height)];
        
        // Other properties of the day label
        aDayLabel.textColor = [UIColor darkTextColor];
        aDayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        aDayLabel.backgroundColor = [UIColor clearColor];
        aDayLabel.textAlignment = UITextAlignmentCenter;
        
        // Get the offset for the weekday
        int aWeekday = i + weekday;
        if (aWeekday < 1) {
            aWeekday += 7;
        } else if (aWeekday > 7) {
            aWeekday -= 7;
        }
        
        // Hours
        NSString *someHours;
        
        // Set the label's text based on the offset
        switch (aWeekday) {
            case Sunday:
                aDayLabel.text = @"Sunday";
                someHours = self.location.sundayHours;
                break;
            case Monday:
                aDayLabel.text = @"Monday";
                someHours = self.location.mondayHours;
                break;
            case Tuesday:
                aDayLabel.text = @"Tuesday";
                someHours = self.location.tuesdayHours;
                break;
            case Wednesday:
                aDayLabel.text = @"Wednesday";
                someHours = self.location.wednesdayHours;
                break;
            case Thursday:
                aDayLabel.text = @"Thursday";
                someHours = self.location.thursdayHours;
                break;
            case Friday:
                aDayLabel.text = @"Friday";
                someHours = self.location.fridayHours;
                break;
            case Saturday:
                aDayLabel.text = @"Saturday";
                someHours = self.location.saturdayHours;
                break;
                
            default:
                break;
        }
        
        if (i == 0) {
            aDayLabel.text = [NSString stringWithFormat:@"%@ (Today)", aDayLabel.text];
        }
        
        // Create date labels
        aDateLabel = [[UILabel alloc] init];
        [self.dateScrollView addSubview:aDateLabel];
        [aDateLabel setFrame:CGRectMake(self.dateLabel.left + self.dateScrollView.width * (i + 3), self.dateLabel.top, self.dateLabel.width, self.dateLabel.height)];
        
        // Date label properties
        aDateLabel.textColor = [UIColor darkTextColor];
        aDateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        aDateLabel.backgroundColor = [UIColor clearColor];
        aDateLabel.textAlignment = UITextAlignmentCenter;
        
        // Set the text
        aDateLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:i * 24 * 60 * 60]];
        
        // Create hours labels
        anHoursLabel = [[UILabel alloc] init];
        [self.dateScrollView addSubview:anHoursLabel];
        [anHoursLabel setFrame:CGRectMake(self.hoursLabel.left + self.dateScrollView.width * (i + 3), self.hoursLabel.top, self.hoursLabel.width, self.hoursLabel.height)];
        
        // Hours label properties
        anHoursLabel.textColor = [UIColor darkGrayColor];
        anHoursLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        anHoursLabel.backgroundColor = [UIColor clearColor];
        anHoursLabel.textAlignment = UITextAlignmentCenter;
        
        // TODO: Get the hours from the location object
//        anHoursLabel.text = @"8 AM - 9 PM";
        NSArray *hoursArray = [self parseHoursFromString:someHours];
        anHoursLabel.text = [NSString stringWithFormat:@"%@ - %@", [hoursArray objectAtIndex:0], [hoursArray objectAtIndex:1]];
    }
    
    // Keep track of the currently selected weekday
    self.currentlySelectedWeekday = weekday;
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
            
            // TODO: Add a different image for each location
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

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.dateScrollView.width;
    int page = floor((self.dateScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentlySelectedWeekday = page;
}

#pragma mark - IBActions

- (IBAction)dateRightPressed {
    CGFloat pageWidth = self.dateScrollView.width;
    
    // TODO: Make this work with the currentlySelectedWeekday property
    int page = ((self.dateScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self.dateScrollView setContentOffset:CGPointMake(self.dateScrollView.width * MIN((page + 1), 6), 0) animated:YES];
}

- (IBAction)dateLeftPressed {
    CGFloat pageWidth = self.dateScrollView.width;
    
    // TODO: Make this work with the currentlySelectedWeekday property
    int page = ((self.dateScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self.dateScrollView setContentOffset:CGPointMake(self.dateScrollView.width * MAX((page - 1), 0), 0) animated:YES];
}


@end
