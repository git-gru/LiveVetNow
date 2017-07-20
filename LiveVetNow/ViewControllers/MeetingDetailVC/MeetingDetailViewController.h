//
//  MeetingDetailViewController.h
//  LiveVetNow
//
//  Created by Apple on 03/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"

@interface MeetingDetailViewController : UIViewController

@property(nonatomic,strong) Appointment *selectedAppointment;

@end
