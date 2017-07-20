//
//  FindYourVetViewController.h
//  LiveVetNow
//
//  Created by apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "VetManager.h"

@interface FindYourVetViewController : UIViewController<PayPalPaymentDelegate,PubPresenceDelegate>

@property(nonatomic,strong)NSString *type;
@property (assign, nonatomic) BOOL showOnlineSegmentOnly;

@end

