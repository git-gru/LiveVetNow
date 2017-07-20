//
//  NotificationManager.m
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "NotificationManager.h"
#import "Constants.h"
#import "Message.h"

@implementation NotificationManager


- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Notifications Custom Delegate

-(void)notificationManagerShowInAppNotification:(NSDictionary *)notification {
    if ([notification objectForKey:@"type"]) {
        NSString *pushType = [notification objectForKey:@"type"];
        if(![[notification objectForKey:@"senderID"] isEqualToString:model_manager.profileManager.owner.userID]) {
            if ([pushType isEqualToString:@"callStarted"]) {
                kAppDelegate.isCall = YES;
            }
            else if([pushType isEqualToString:@"callDeclined"]){
                kAppDelegate.isCall = NO;
            }
            [kAppDelegate showNotificationView:[notification objectForKey:@"text"]];
        }
    }
}

-(void)notificationManagerRedirectionForNotification:(NSDictionary *)notification {
    NSString *pushType = [notification objectForKey:@"type"];
    if([pushType isEqualToString:@"appointmentRequest"]) {
        if (kAppDelegate.isVet) {
            NSString *appointmentId = [notification objectForKey:@"appointmentID"];
            //goto Vet Appointment detail's with AppointmentID
            [self pushToVetAppointmentDetailsView:appointmentId];
        }
    }
    else if([pushType isEqualToString:@"appointmentAccepted"] || [pushType isEqualToString:@"appointmentRejected"]) {
        if (!kAppDelegate.isVet) {
            NSString *appointmentId = [notification objectForKey:@"appointmentID"];
            //goto Client Appointment detail's with AppointmentID
            [self pushToClientAppointmentDetailsView:appointmentId];
        }
    }
    else if([pushType isEqualToString:@"appointmentConfirmed"]) {
        if (kAppDelegate.isVet) {
            NSString *appointmentId = [notification objectForKey:@"appointmentID"];
            [model_manager.appointment_Manager getTransactionsList:nil withCompletionBlock:^(BOOL success, NSString *message) {
                if (success) {
                    
                }
                else {
                   // [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
                }
            }];
            //goto Vet Appointment detail's with AppointmentID
            [self pushToVetAppointmentDetailsView:appointmentId];
        }
    }
    else if([pushType isEqualToString:@"appointmentCancelled"]) {
        if (kAppDelegate.isVet) {
            NSString *appointmentId = [notification objectForKey:@"appointmentID"];
            //goto Client Appointment detail's with AppointmentID
            [self pushToClientAppointmentDetailsView:appointmentId];
        }
        else {
            NSString *appointmentId = [notification objectForKey:@"appointmentID"];
            //goto Vet Appointment detail's with AppointmentID
            [self pushToVetAppointmentDetailsView:appointmentId];
        }
    }
    else if([pushType isEqualToString:@"callStarted"] || [pushType isEqualToString:@"callDeclined"]) {
        NSString *appointmentId = [notification objectForKey:@"appointmentID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"callStarted" object:appointmentId];
        [self pushToCallScreen:appointmentId];
    }
}

#pragma mark - Redirection To View Controller

-(void)pushToCallScreen:(NSString*)appointmentID {
    
    

}


-(void)pushToClientAppointmentsListView:(NSString*)appointmentID {
    
}


-(void)pushToVetAppointmentsListView:(NSString*)appointmentID {
  
}

-(void)pushToVetAppointmentDetailsView:(NSString*)appointmentId {
  
}

-(void)pushToClientAppointmentDetailsView:(NSString*)appointmentID {

}

#pragma mark - Notifications To Be Sent To Vet By Client

-(void) notifiyVetAppointmentRequest:(NSString*)channel appointmentID:(NSString*)appointmentId {
        Message *newMessage = [Message new];
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
        newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.owner.userID, strTimeStamp];
        newMessage.messageType = MessageTypeAppointmentRequest;
        newMessage.messageText = [NSString stringWithFormat:@"%@ Sent you a Appointment Request",[model_manager.profileManager.owner.name capitalizedString]];
        newMessage.time = [NSDate date];
        newMessage.appointmentID  = appointmentId;
        [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.owner.name userId:model_manager.profileManager.owner.userID typeOfCall:@""];
}

-(void) notifiyVetAppointmentRequestConfirmed:(NSString*)channel appointmentID:(NSString*)appointmentId {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.owner.userID, strTimeStamp];
    newMessage.messageType = MessageTypeAppointmentRequestConfirmed;
    newMessage.messageText = [NSString stringWithFormat:@"%@ Confirmed a Appointment Request",[model_manager.profileManager.owner.name capitalizedString]];
    newMessage.time = [NSDate date];
    newMessage.appointmentID  = appointmentId;
    [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.owner.name userId:model_manager.profileManager.owner.userID typeOfCall:@""];
}

-(void) notifiyVetCallStarted:(NSString*)channel callType:(NSString*)callType appointmentID:(NSString*)appointmentId {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.owner.userID, strTimeStamp];
    newMessage.messageType = MessageTypeCallStarted;
    newMessage.messageText = [NSString stringWithFormat:@"%@ is calling...",[model_manager.profileManager.owner.name capitalizedString]];
    newMessage.time = [NSDate date];
    newMessage.appointmentID  = appointmentId;
    [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.owner.name userId:model_manager.profileManager.owner.userID typeOfCall:callType];
}

#pragma mark - Notifications To Be Sent To Client By Vet

-(void) notifiyClientAppointmentRequestAccepted:(NSString*)channel appointmentID:(NSString*)appointmentId {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.ownerVet.vetId, strTimeStamp];
    newMessage.messageType = MessageTypeAppointmentRequestAccepted;
    newMessage.messageText = [NSString stringWithFormat:@"%@ Accepted your Appointment request",[model_manager.profileManager.ownerVet.name capitalizedString]];
    newMessage.time = [NSDate date];
    newMessage.appointmentID  = appointmentId;
    [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.ownerVet.name userId:model_manager.profileManager.ownerVet.vetId typeOfCall:@""];
}

-(void) notifiyClientAppointmentRequestRejected:(NSString*)channel appointmentID:(NSString*)appointmentId {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.ownerVet.vetId, strTimeStamp];
    newMessage.messageType = MessageTypeAppointmentRequestRejected;
    newMessage.messageText = [NSString stringWithFormat:@"%@ Rejected your Appointment request",[model_manager.profileManager.ownerVet.name capitalizedString]];
    newMessage.time = [NSDate date];
    newMessage.appointmentID  = appointmentId;
    [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.ownerVet.name userId:model_manager.profileManager.ownerVet.vetId typeOfCall:@""];
}

- (void) notifiyClientCallDeclined:(NSString*)channel callType:(NSString*)callType  appointmentID:(NSString*)appointmentId {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.ownerVet.vetId, strTimeStamp];
    newMessage.messageType = MessageTypeCallDeclined;
    newMessage.messageText = @"Audio Call Declined";
    newMessage.time = [NSDate date];
    newMessage.appointmentID  = appointmentId;
    [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.ownerVet.name userId:model_manager.profileManager.ownerVet.vetId typeOfCall:callType];
//    if(kAppDelegate.inAppNotificationSound.isPlaying)
//        [kAppDelegate.inAppNotificationSound stop];
}

#pragma mark - Notifications That Can Be Sent By Client Or Vet

-(void) notifiyAppointmentRequestCancelled:(NSString*)channel appointmentID:(NSString*)appointmentId {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageType = MessageTypeAppointmentRequestCancelled;
    newMessage.appointmentID  = appointmentId;
    newMessage.time = [NSDate date];
    if (kAppDelegate.isVet) {
        newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.ownerVet.vetId, strTimeStamp];
        newMessage.messageText = [NSString stringWithFormat:@"%@ Cancelled a Appointment Request",[model_manager.profileManager.ownerVet.name capitalizedString]];
        [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.ownerVet.name userId:model_manager.profileManager.ownerVet.vetId typeOfCall:@""];
    }
    else {
        newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.owner.userID, strTimeStamp];
        newMessage.messageText = [NSString stringWithFormat:@"%@ Cancelled a Appointment Request",[model_manager.profileManager.owner.name capitalizedString]];
        [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.owner.name userId:model_manager.profileManager.owner.userID typeOfCall:@""];
    }
}

-(void) notifiyEmail:(NSString*)channel {
    Message *newMessage = [Message new];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    newMessage.messageType = MessageTypeEmail;
    newMessage.time = [NSDate date];
    if (kAppDelegate.isVet) {
        newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.ownerVet.vetId, strTimeStamp];
        newMessage.messageText = [NSString stringWithFormat:@"%@ Sent You a New Message",[model_manager.profileManager.ownerVet.name capitalizedString]];
        [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.ownerVet.name userId:model_manager.profileManager.ownerVet.vetId typeOfCall:@""];
    }
    else {
        newMessage.messageID = [NSString stringWithFormat:@"%@_%@",model_manager.profileManager.owner.userID, strTimeStamp];
        newMessage.messageText = [NSString stringWithFormat:@"%@ Sent You a New Message",[model_manager.profileManager.owner.name capitalizedString]];
        [model_manager.chatVendor sendMessageViaPubNub:newMessage toChannel:channel name:model_manager.profileManager.owner.name userId:model_manager.profileManager.owner.userID typeOfCall:@""];
    }
}

@end
