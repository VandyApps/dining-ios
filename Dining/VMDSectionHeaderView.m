//
//  VMDSectionHeaderView.m
//  Dining
//
//  Created by Scott Andrus on 2/8/13.
//  Copyright (c) 2013 VandyMobile. All rights reserved.
//

#import "VMDSectionHeaderView.h"

@implementation VMDSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VMDSectionHeaderView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    if (self) {
        // Initialization code
        self.headerLabel.font = [UIFont fontWithName:@"Suplexmentary Comic NC" size:16];
        self.headerLabel.textColor = [UIColor blackColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
