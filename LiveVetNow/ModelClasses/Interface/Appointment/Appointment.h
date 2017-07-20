//
//  Appointment.h
//  LiveVetNow
//
//  Created by apple on 30/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Appointment : NSObject

@property (strong,nonatomic) NSString *apt_id;
@property (strong,nonatomic) NSString *user_id;
@property (strong,nonatomic) NSString *doctor_id;
@property (strong,nonatomic) NSString *pet_id;
@property (strong,nonatomic) NSString *pet_type;
@property (strong,nonatomic) NSString *notes;

@property (strong,nonatomic) NSString *appointment_datetime;
@property (strong,nonatomic) NSString *appointmentTime;
@property (strong,nonatomic) NSString *appointmentDate;
@property (strong,nonatomic) NSString *pet_age;
@property (strong,nonatomic) NSString *pet_image_url;
@property (strong,nonatomic) NSString *pet_name;
@property (strong,nonatomic) NSString *pet_sex;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSString *user_image_url;
@property (strong,nonatomic) NSString *doctor_state;
@property (strong,nonatomic) NSString *doctor_speciality;
@property (strong,nonatomic) NSString *doctor_name;
@property (strong,nonatomic) NSString *doctor_image_url;
@property (strong,nonatomic) NSString *appointment_status;
@property (strong,nonatomic) NSMutableArray *ques_answers;

@end
