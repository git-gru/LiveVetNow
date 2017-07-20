//
//  VetProfileForPetOwnerViewController.h
//  LiveVetNow
//
//  Created by apple on 16/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "Vet.h"
#import "VetManager.h"

@interface VetProfileForPetOwnerViewController : UIViewController<PayPalPaymentDelegate, PubPresenceDelegate>

@property(nonatomic,strong) Vet *selectedVet;
@property(nonatomic,strong) NSMutableArray *vetFeedback;
@property(nonatomic,strong) NSString *type;
@end
