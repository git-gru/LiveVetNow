//
//  VetProfileTableViewCell.h
//  LiveVetNow
//
//  Created by Apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VetProfileTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblOverview;
@property (strong, nonatomic) IBOutlet UILabel *lblComment;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewClient;
@property (strong, nonatomic) IBOutlet UILabel *lblClientName;

@end
