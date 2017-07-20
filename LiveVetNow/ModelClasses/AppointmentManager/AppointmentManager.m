//
//  AppointmentManager.m
//  LiveVetNow
//
//  Created by Apple on 28/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "AppointmentManager.h"
#import "Constants.h"
#import "Transaction.h"
#import "Appointment.h"

@implementation AppointmentManager

- (id)init {
    self = [super init];
    if (self) {
        self.arrayAppointments = [NSMutableArray new];
        self.arrayTransactions = [NSMutableArray new];
        self.arrayUpcomingAppointments = [NSMutableArray new];
        self.arrayNewRequests = [NSMutableArray new];
        self.arrayAppointmentsHistory = [NSMutableArray new];
        self.weeklyEarning = @"";
        self.totalEarning = @"";
    }
    return self;
}


-(void)getDoctorAvailability:(NSDictionary*)params withHandler:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"get_doctor_availability" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:params onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if (statusCode==200) {
            if (success) {
                completionBlock(true,message);
            }
            else {
                completionBlock(false,message);
            }
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)bookAppointmentWithParams:(NSDictionary*)params withHandler:(void (^)(BOOL,NSString*,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"book_appointment" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:params onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            completionBlock(true,[NSString stringWithFormat:@"%@",[[json objectForKey:@"data"] objectForKey:@"appointment_id"]],message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,@"",message);
            }
            else if (statusCode == 422) {
                completionBlock(false,@"",message);
            }
            else if (statusCode == 401) {
                completionBlock(false,@"",message);
            }
            else if (statusCode == 500) {
                completionBlock(false,@"",message);
            }
        }
    }];
}

-(void)getAppointmentsList:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"appointment_list" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayAppointments removeAllObjects];
                    NSMutableArray *arrAppointments = [json objectForKey:@"data"];
                    for (id object in arrAppointments) {
                        // do something with object
                        DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Appointment class]];
                        Appointment *currentAppointment = [parser parseDictionary:object];
                        currentAppointment.appointmentTime = [model_manager.appointment_Manager getTimeStringFromDate:[model_manager.appointment_Manager dateFromTimestamp:currentAppointment.appointment_datetime]];
                        currentAppointment.appointmentDate = [model_manager.appointment_Manager getDateStringFromDate:[model_manager.appointment_Manager dateFromTimestamp:currentAppointment.appointment_datetime]];
                        [self.arrayAppointments addObject:currentAppointment];
                    }
                if (kAppDelegate.isVet) {
                [self filterNewRequests];
                [self filterUpcomingAppointments];
                }
            }
            if (kAppDelegate.isFromPushNotification) {
                 [self.appointmentDelegate fetchedAppointmentList];
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)setAppointmentStatus:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"appointment_status" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)getTransactionsList:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"get_transaction_list" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {

        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"]boolValue];

        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayTransactions removeAllObjects];
                if ([[json objectForKey:@"data"] valueForKey:@"transaction_list"]) {
                NSMutableArray *arrTransactions = [[json objectForKey:@"data"] valueForKey:@"transaction_list"];
                for (id object in arrTransactions) {
                    // do something with object
                    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Transaction class]];
                    Transaction *currentTransaction = [parser parseDictionary:object];
                    [self.arrayTransactions addObject:currentTransaction];
                }
            }
                if ([[json objectForKey:@"data"] valueForKey:@"this_week_earnings"]) {
                    self.weeklyEarning = [[json objectForKey:@"data"] valueForKey:@"this_week_earnings"];
                }
                if ([[json objectForKey:@"data"] valueForKey:@"total_earnings"]) {
                    self.totalEarning = [[json objectForKey:@"data"] valueForKey:@"total_earnings"];
                }
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)getAppointmentHistory:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
  
    [model_manager.request_Manager requestWithPath:@"appointment_history" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"]boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayAppointmentsHistory removeAllObjects];
                NSMutableArray *arrAppointments = [json objectForKey:@"data"];
                for (id object in arrAppointments) {
                    // do something with object
                    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Appointment class]];
                    Appointment *currentAppointment = [parser parseDictionary:object];
                    currentAppointment.appointmentTime = [model_manager.appointment_Manager getTimeStringFromDate:[model_manager.appointment_Manager dateFromTimestamp:currentAppointment.appointment_datetime]];
                    currentAppointment.appointmentDate = [model_manager.appointment_Manager getDateStringFromDate:[model_manager.appointment_Manager dateFromTimestamp:currentAppointment.appointment_datetime]];
                    [self.arrayAppointmentsHistory addObject:currentAppointment];
                }
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

- (void)getWeeklyEarning {
//    if (kAppDelegate.isVet) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"appointment_status CONTAINS[cd] %@",@"pending"];
//        if ([self.arrayAppointments filteredArrayUsingPredicate:predicate].count >0) {
//            self.arrayNewRequests = [[self.arrayAppointments filteredArrayUsingPredicate:predicate] mutableCopy];
//        }
//    }
}

- (void)getTotalEarning {
    if (kAppDelegate.isVet) {
        for (id object in self.arrayTransactions) {
            // do something with object
            //self.totalEarned = self.totalEarned + [object];
        }
    }
}

- (void)filterNewRequests {
    [self.arrayNewRequests removeAllObjects];
    if (kAppDelegate.isVet) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"appointment_status CONTAINS[cd] %@",@"pending"];
        if ([self.arrayAppointments filteredArrayUsingPredicate:predicate].count >0) {
            self.arrayNewRequests = [[self.arrayAppointments filteredArrayUsingPredicate:predicate] mutableCopy];
        }
    }
}

- (void)filterUpcomingAppointments {
    [self.arrayUpcomingAppointments removeAllObjects];
    if (kAppDelegate.isVet) {
        NSMutableArray *arr1 = [NSMutableArray new];
        NSMutableArray *arr2 = [NSMutableArray new];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"appointment_status CONTAINS[cd] %@",@"accepted"];
        if ([self.arrayAppointments filteredArrayUsingPredicate:predicate].count >0) {
            arr1 = [[self.arrayAppointments filteredArrayUsingPredicate:predicate] mutableCopy];
        }
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat: @"appointment_status CONTAINS[cd] %@",@"confirmed"];
        if ([self.arrayAppointments filteredArrayUsingPredicate:predicate1].count >0) {
            arr2 = [[self.arrayAppointments filteredArrayUsingPredicate:predicate1] mutableCopy];
        }
        [self.arrayUpcomingAppointments addObjectsFromArray: arr1];
        [self.arrayUpcomingAppointments addObjectsFromArray: arr2];
    }
}



-(void)addNote:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"add_apt_note" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)addReview:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"review_doctor" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}





-(NSString *) getTimeStringFromDate:(NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];//[[NSDateFormatter alloc] init];
    [format setDateFormat:kUTCTimeFormat];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [format setTimeZone:timeZone];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [format setLocale:enUSPOSIXLocale];
    
    NSString *dateString = [format stringFromDate:date];
    return dateString;
}

-(NSString *) getDateStringFromDate:(NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];//[[NSDateFormatter alloc] init];
    [format setDateFormat:kUTCDateFormat];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [format setTimeZone:timeZone];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [format setLocale:enUSPOSIXLocale];
    
    NSString *dateString = [format stringFromDate:date];
    return dateString;
}

-(NSDate *)dateFromTimestamp:(NSString *)strTimeStamp {
    // Convert NSString to NSTimeInterval
    NSTimeInterval seconds = [strTimeStamp doubleValue];
    
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSDate *converted =[dateFormatter dateFromString:[dateFormatter stringFromDate:epochNSDate]];
    return converted;
}

-(NSString *)timestampFromDate:(NSDate *)date {
    long long timeInterval =  [@(floor([date timeIntervalSince1970])) longLongValue];
    NSString *strTime = [NSString stringWithFormat:@"%lli",timeInterval];
    return strTime;
}

-(NSDate *) getDateFromString:(NSString *)dateString {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];//[[NSDateFormatter alloc] init];
    [format setDateFormat:kUTCFormat];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [format setTimeZone:timeZone];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [format setLocale:enUSPOSIXLocale];
    
    NSDate *convertedDate = [format dateFromString:dateString];
    return convertedDate;
}

@end
