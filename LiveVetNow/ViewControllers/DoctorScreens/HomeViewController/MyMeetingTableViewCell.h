//
//  MyMeetingTableViewCell.h
//  LiveVetNow
//
//  Created by Apple on 29/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMeetingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewVet;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPet;
@property (weak, nonatomic) IBOutlet UILabel *lblPetName;
@property (weak, nonatomic) IBOutlet UILabel *lblPetInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblClientName;
@property (weak, nonatomic) IBOutlet UIButton *btnClientLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnDate;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnAccpetConstraint;
@property (strong, nonatomic) IBOutlet UIButton *statusButton;

@end
