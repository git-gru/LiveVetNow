//
//  UpcomingMeetingsTableViewCell.h
//  LiveVetNow
//
//  Created by Apple on 24/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpcomingMeetingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnViewDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewVet;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPet;
@property (weak, nonatomic) IBOutlet UILabel *lblPetName;
@property (weak, nonatomic) IBOutlet UILabel *lblPetInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblVetName;
@property (weak, nonatomic) IBOutlet UIButton *btnVetLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnDate;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;


@end
