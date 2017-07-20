//
//  EmailDetailViewController.h
//  LiveVetNow
//
//  Created by apple on 06/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "ViewController.h"

@interface EmailDetailViewController : ViewController

@property(nonatomic,retain)NSString *receiverId;
@property(nonatomic,retain)NSString *receiverName;
@property(nonatomic,assign) BOOL fromPaymentSuccess;

@end
