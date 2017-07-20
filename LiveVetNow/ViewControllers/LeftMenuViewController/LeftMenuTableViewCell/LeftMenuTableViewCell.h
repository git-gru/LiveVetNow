//
//  LeftMenuTableViewCell.h
//  LiveVetNow
//
//  Created by Apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIView *viewSeparator;
@property (strong, nonatomic) IBOutlet UIButton *btnNotificationCount;

@end
