//
//  VMDListCell.h
//  Dining
//
//  Created by Scott Andrus on 2/7/13.
//  Copyright (c) 2013 VandyMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLocation.h"


@protocol VMDListCellDelegate <NSObject>

@required

- (void)setWayPointToLocation:(DLocation *)location;

@end

@interface VMDListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UIButton *goToButton;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIView *cellBg;

@property (strong, nonatomic) id<VMDListCellDelegate> delegate;

@end
