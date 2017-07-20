//
//  MyMeetingTableViewCell.m
//  LiveVetNow
//
//  Created by Apple on 29/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "MyMeetingTableViewCell.h"
#import "UIButton+Customization.h"

@implementation MyMeetingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btnAccept = [UIButton addBorderToButton:self.btnAccept withBorderColour:[UIColor clearColor]];
    self.btnReject = [UIButton addBorderToButton:self.btnReject withBorderColour:[UIColor blackColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
