//
//  UpcomingMeetingsTableViewCell.m
//  LiveVetNow
//
//  Created by Apple on 24/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "UpcomingMeetingsTableViewCell.h"
#import "UIButton+Customization.h"

@implementation UpcomingMeetingsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.btnViewDetail = [UIButton addBorderToButton:self.btnViewDetail withBorderColour:[UIColor clearColor]];
    self.btnCancel = [UIButton addBorderToButton:self.btnCancel withBorderColour:[UIColor blackColor]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
