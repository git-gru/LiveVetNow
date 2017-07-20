//
//  AppointmentManager.h
//  LiveVetNow
//
//  Created by Apple on 28/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppointmentManagerDelegate <NSObject>

@optional
-(void)fetchedAppointmentList;

@end

@interface AppointmentManager : NSObject

@property(weak,nonatomic) id<AppointmentManagerDelegate> appointmentDelegate;
@property(nonatomic,retain) NSMutableArray *arrayAppointments;
@property(nonatomic,retain) NSMutableArray *arrayTransactions;
@property(nonatomic,retain) NSMutableArray *arrayNewRequests;
@property(nonatomic,retain) NSMutableArray *arrayUpcomingAppointments;
@property(nonatomic,retain) NSMutableArray *arrayAppointmentsHistory;

@property(nonatomic,retain) NSString* totalEarning;
@property(nonatomic,retain) NSString* weeklyEarning;

-(void)bookAppointmentWithParams:(NSDictionary*)params withHandler:(void (^)(BOOL,NSString*,NSString*))completionBlock;
-(void)getAppointmentsList:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)setAppointmentStatus:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)getTransactionsList:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)getDoctorAvailability:(NSDictionary*)params withHandler:(void (^)(BOOL,NSString*))completionBlock;
-(void)getAppointmentHistory:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)addNote:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)addReview:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(NSString *)getTimeStringFromDate:(NSDate *)date;
-(NSString *)getDateStringFromDate:(NSDate *)date;
-(NSDate *)dateFromTimestamp:(NSString *)strTimeStamp;
-(NSString *)timestampFromDate:(NSDate *)date;
-(NSDate *) getDateFromString:(NSString *)date;


@end
