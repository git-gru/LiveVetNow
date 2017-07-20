//
//  ReviewViewController.h
//  LiveVetNow
//
//  Created by Apple on 31/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vet.h"
#import "PayPalMobile.h"

@interface ReviewViewController : UIViewController <PayPalPaymentDelegate>

@property(nonatomic,strong) NSString *appointmentID;
@property(nonatomic,strong) NSString *appointmentType;

@property(nonatomic,strong) Vet *currentVet;

@end
