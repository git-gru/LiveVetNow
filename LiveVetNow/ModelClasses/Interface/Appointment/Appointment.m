//
//  Appointment.m
//  LiveVetNow
//
//  Created by apple on 30/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "Appointment.h"
#import "Constants.h"

@implementation Appointment

- (id)init {
    self = [super init];
    if(self) {
        // Work your initialising magic here as you normally would
        self.appointment_datetime = @"";
        self.apt_id = @"";
        self.user_id = @"";
        self.doctor_id = @"";
        self.pet_id = @"";
        self.pet_type = @"";

        self.pet_age = @"";
        self.pet_image_url = @"";
        self.pet_name = @"";
        self.pet_sex = @"";
        
        self.doctor_state = @"";
        self.doctor_speciality = @"";
        self.doctor_name = @"";
        self.doctor_image_url = @"";
        self.user_name = @"";
        self.user_image_url = @"";
        self.appointment_status = @"";
        self.appointmentTime = @"";
        self.appointmentDate = @"";
        self.ques_answers = [NSMutableArray new];
    }
    return self;
}


@end
