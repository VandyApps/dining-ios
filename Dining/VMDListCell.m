//
//  VMDListCell.m
//  Dining
//
//  Created by Scott Andrus on 2/7/13.
//  Copyright (c) 2013 VandyMobile. All rights reserved.
//

#import "VMDListCell.h"
#import "VMDListViewController.h"

@implementation VMDListCell

@synthesize nameLabel, categoryLabel, goToButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    // Initialization code
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DiningCellView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.goToButton.imageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)goToPressed:(UIButton *)sender {
    
    if ([self.delegate isKindOfClass:[VMDListViewController class]]) {
        VMDListViewController *vmdlvc = (VMDListViewController *)self.delegate;
        NSIndexPath *indexPath = [[vmdlvc tableView] indexPathForCell:self];
        [self.delegate setWayPointToLocation:[[vmdlvc.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }
}

@end
