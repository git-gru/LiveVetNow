//
//  EmailListingTableViewCell.h
//  LiveVetNow
//
//  Created by apple on 06/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailListingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSender;
@property (weak, nonatomic) IBOutlet UILabel *lblSenderName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;

@end
