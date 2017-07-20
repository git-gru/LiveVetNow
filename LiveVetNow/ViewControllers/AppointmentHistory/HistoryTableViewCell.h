//
//  HistoryTableViewCell.h
//  LiveVetNow
//
//  Created by Apple on 10/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgViewSender;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblDateTime;

@end
