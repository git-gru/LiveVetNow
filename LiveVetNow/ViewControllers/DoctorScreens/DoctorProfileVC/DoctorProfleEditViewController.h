//
//  DoctorProfleEditViewController.h
//  LiveVetNow
//
//  Created by Apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pet.h"


@interface DoctorProfleEditViewController : UIViewController
@property(nonatomic,strong)NSString* editType;
@property(nonatomic,strong)Pet* currentPet;

@end
