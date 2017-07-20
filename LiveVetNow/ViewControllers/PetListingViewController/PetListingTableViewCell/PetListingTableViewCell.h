//
//  PetListingTableViewCell.h
//  LiveVetNow
//
//  Created by Apple on 24/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PetListingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPet;
@property (weak, nonatomic) IBOutlet UILabel *lblPetName;
@property (weak, nonatomic) IBOutlet UILabel *lblPetInfo;

@end
