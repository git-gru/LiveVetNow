//
//  FindYourVetTableViewCell.h
//  LiveVetNow
//
//  Created by apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindYourVetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewVet;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeciality;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnVideoCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSchedule;
@property (weak, nonatomic) IBOutlet UIButton *btnMessage;
@property (strong, nonatomic) IBOutlet UIView *customSeparator;
@property (strong, nonatomic) IBOutlet UIView *statusDot;

@end
