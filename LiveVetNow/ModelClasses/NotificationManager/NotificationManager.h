//
//  NotificationManager.h
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject

-(void)notificationManagerRedirectionForNotification:(NSDictionary *)notification;
-(void)notificationManagerShowInAppNotification:(NSDictionary *)notification;

//Client
-(void) notifiyVetAppointmentRequest:(NSString*)channel appointmentID:(NSString*)appointmentId;
-(void) notifiyVetAppointmentRequestConfirmed:(NSString*)channel appointmentID:(NSString*)appointmentId;
-(void) notifiyVetCallStarted:(NSString*)channel callType:(NSString*)callType appointmentID:(NSString*)appointmentId;

//Vet
-(void) notifiyClientAppointmentRequestAccepted:(NSString*)channel appointmentID:(NSString*)appointmentId;
-(void) notifiyClientAppointmentRequestRejected:(NSString*)channel appointmentID:(NSString*)appointmentId;
- (void) notifiyClientCallDeclined:(NSString*)channel callType:(NSString*)callType  appointmentID:(NSString*)appointmentId;

//Both
-(void) notifiyAppointmentRequestCancelled:(NSString*)channel appointmentID:(NSString*)appointmentId;
-(void) notifiyEmail:(NSString*)channel ;

@end
