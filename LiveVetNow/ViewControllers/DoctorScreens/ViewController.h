//
//  ViewController.h
//  calling
//
//  Created by Apple on 20/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vet.h"
@interface ViewController : UIViewController

@property(nonatomic,strong)   NSDictionary *dictSessionData;
@property(nonatomic,strong) Vet *currentVet;
@property(nonatomic,strong) NSString *appointmentID;

@end

