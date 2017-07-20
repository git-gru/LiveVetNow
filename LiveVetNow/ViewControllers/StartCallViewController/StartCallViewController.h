//
//  StartCallViewController.h
//  LiveVetNow
//
//  Created by Apple on 21/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vet.h"

@interface StartCallViewController : UIViewController
@property(nonatomic,strong) NSString *appointmentID;
@property(nonatomic,strong) Vet *currentVet;

@end
