//
//  PubnubChatClient.m
//

#import "PubnubChatClient.h"
#import "Constants.h"

@interface PubnubChatClient ()<PNObjectEventListener> {
    
}

// Stores reference on PubNub client to make sure what it won't be released.
@property (nonatomic) PubNub *client;

// Stores reference on PubNub client configuration
@property (nonatomic, strong) PNConfiguration *pubnubConfig;

@end

@implementation PubnubChatClient

//init pubnub over here
-(BOOL)initChatClient:(NSString*)userID broadcast_id:(NSString*)broadcastingID {
  
    
    // Initialize and configure PubNub client instance
    self.pubnubConfig = [PNConfiguration configurationWithPublishKey:kPublisherKeyPubNub subscribeKey:kSubscriptionKeyPubNub];
    self.pubnubConfig.uuid = userID;
    
    //use secure connection
    self.pubnubConfig.TLSEnabled=YES;
    
    self.pubnubConfig.presenceHeartbeatInterval=5.0f; //frequency in which the client sends heartbeats to the server.
    self.pubnubConfig.presenceHeartbeatValue=15.0f;  //presence server timeout
    
    self.client = [PubNub clientWithConfiguration:self.pubnubConfig];
    [self.client addListener:self];
    
    if (kAppDelegate.isVet) {
         // Subscribe to Vet channel without presence observation for push
        [self subscribeToChannels:[NSArray arrayWithObjects:userID, nil] presenceRequired:NO];
        // Subscribe to Vet Status Broadcast channel with presence observation
        [self subscribeToChannels:[NSArray arrayWithObjects:broadcastingID, nil] presenceRequired:YES];
    }
    else {
        // Subscribe to Vet channel without presence observation for push
        [self subscribeToChannels:[NSArray arrayWithObjects:userID, nil] presenceRequired:NO];
    }
    self.isClientInitialized = YES;
    
    return YES;
}

-(BOOL)subscribeToChannels:(NSArray*)channels presenceRequired:(BOOL)presence {
    NSMutableArray *channelsToSubscribe = [NSMutableArray new];
    for (int i = 0; i < channels.count; i++) {
        if(![self.client isSubscribedOn:[channels objectAtIndex:i]]) {
            [channelsToSubscribe addObject:[channels objectAtIndex:i]];
        }
    }
    if(channelsToSubscribe.count>0) {
        [self.client subscribeToChannels: channelsToSubscribe withPresence:presence];
    }
    return YES;
}

-(void)getChannelPresence:(Vet*)vet {
    [self.client hereNowForChannel: vet.broadcasting_id withVerbosity:PNHereNowState completion:^(PNPresenceChannelHereNowResult *result,PNErrorStatus *status) {
        // Check whether request successfully completed or not.
        if (!status.isError) {
            // Handle downloaded presence information using:
            //   result.data.uuids - list of uuids.
            //   result.data.occupancy - total number of active subscribers.
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", vet.vetId];
            NSArray *filteredUsers = [result.data.uuids filteredArrayUsingPredicate:predicate];
            if(filteredUsers.count>0) {
                if ([[filteredUsers objectAtIndex:0] valueForKey:@"state"]) {
                    vet.vetStatus = @"Online";
                }
                else
                    vet.vetStatus = @"Online";
            }
            else {
                vet.vetStatus = @"Offline";
            }
            [model_manager.vetManager filterOnlineVets];
            [model_manager.vetManager filterOfflineVets];
            if ([model_manager.vetManager.vetManagerDelegate respondsToSelector:@selector(notifyVetStatus)])
            {
            [model_manager.vetManager.vetManagerDelegate notifyVetStatus];
            }
        }
        // Request processing failed.
        else {
            // Request can be resent using:
            [status retry];
        }
    }];
}

-(BOOL)unSubscribeToChannels:(NSArray*)channels {
    [self.client unsubscribeFromChannels:channels withPresence:YES];
    
    //    if(self.devicePushToken){
    //        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:self.devicePushToken andCompletion:^(PNAcknowledgmentStatus *status) {
    //                                          // Check whether request successfully completed or not.
    //                                          if (!status.isError) {
    //
    //                                              // Handle successful push notification enabling on passed channels.
    //                                          }
    //                                          // Request processing failed.
    //                                          else {
    //
    //                                              // Handle modification error. Check 'category' property to find out possible issue because
    //                                              // of which request did fail.
    //                                              //
    //                                              // Request can be resent using:
    //                                              [status retry];
    //                                          }
    //                                      }];
    //    }
    return YES;
}

-(BOOL)destroyChatClient {
    [self unSubscribeToChannels:self.client.channels];
    //[self.client unsubscribeFromChannels:self.client.channels withPresence:YES];
    [self.client removeListener:self];
    self.isClientInitialized = NO;
    return YES;
}

-(void)enablePushNotification:(NSString*)channel {
    if(self.devicePushToken) {
        [self.client addPushNotificationsOnChannels:[NSArray arrayWithObjects:channel, nil] withDevicePushToken:self.devicePushToken
                                      andCompletion:^(PNAcknowledgmentStatus *status) {
                                          
                                          // Check whether request successfully completed or not.
                                          if (!status.isError) {
                                              
                                              // Handle successful push notification enabling on passed channels.
                                          }
                                          // Request processing failed.
                                          else {
                                              
                                              // Handle modification error. Check 'category' property to find out possible issue because
                                              // of which request did fail.
                                              //
                                              // Request can be resent using:
                                              [status retry];
                                          }
                                      }];
    }
}

-(void)disablePushNotification:(NSString*)channel {
    if(self.devicePushToken){
        [self.client removePushNotificationsFromChannels:[NSArray arrayWithObjects:channel, nil] withDevicePushToken:self.devicePushToken
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
                                               
                                               // Check whether request successfully completed or not.
                                               if (!status.isError) {
                                                   
                                                   // Handle successful push notification enabling on passed channels.
                                               }
                                               // Request processing failed.
                                               else {
                                                   
                                                   // Handle modification error. Check 'category' property to find out possible issue because
                                                   // of which request did fail.
                                                   //
                                                   // Request can be resent using:
                                                   [status retry];
                                               }
                                           }];
    }
}

-(void)sendMessageViaPubNub:(Message*)message toChannel:(NSString*)channelID name:(NSString*)senderName userId:(NSString*)senderID typeOfCall:(NSString*)callType {
    NSString *contentType;
    if(message.messageType==MessageTypeAppointmentRequest)
        contentType = @"appointmentRequest";
    else if(message.messageType==MessageTypeAppointmentRequestAccepted)
        contentType = @"appointmentAccepted";
    else if(message.messageType==MessageTypeAppointmentRequestRejected)
        contentType = @"appointmentRejected";
    else if(message.messageType==MessageTypeAppointmentRequestCancelled)
        contentType = @"appointmentCancelled";
    else if(message.messageType==MessageTypeAppointmentRequestConfirmed)
        contentType = @"appointmentConfirmed";
    else if(message.messageType==MessageTypeCallStarted)
        contentType = @"callStarted";
    else if(message.messageType==MessageTypeCallDeclined)
        contentType = @"callDeclined";
    else if(message.messageType==MessageTypeEmail)
        contentType = @"email";
    

    
    NSMutableDictionary *msgPayload;
    msgPayload = [NSMutableDictionary dictionaryWithObjectsAndKeys:message.messageID, @"messageID", message.messageText,@"text", senderID,@"senderID", senderName,@"senderName", contentType, @"type", message.time.description,@"time", nil];
    
    if (message.appointmentID.length>0) {
        [msgPayload setValue:message.appointmentID forKey:@"appointmentID"];
    }
    if (callType.length>0) {
        [msgPayload setValue:callType forKey:@"calltype"];
    }
    NSDictionary *pushPayload;
    if(message.messageType == MessageTypeAppointmentRequest) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"default"}, @"type":contentType, @"sender":senderID,@"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    else if(message.messageType == MessageTypeEmail) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"default"}, @"type":contentType, @"sender":senderID,@"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    else if(message.messageType == MessageTypeAppointmentRequestAccepted) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"default"}, @"type":contentType, @"sender":senderID,@"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    else if(message.messageType == MessageTypeAppointmentRequestRejected) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText , @"sound": @"default"}, @"type":contentType, @"sender":senderID,@"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    else if(message.messageType == MessageTypeAppointmentRequestCancelled) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"default"}, @"type":contentType, @"sender":senderID,@"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    else if(message.messageType == MessageTypeAppointmentRequestConfirmed) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"default"}, @"type":contentType, @"sender":senderID,@"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    else if(message.messageType == MessageTypeCallStarted) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"phone_ringing.mp3"}, @"calltype":callType,@"type":contentType, @"sender":senderID, @"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
        }
    else if(message.messageType == MessageTypeCallDeclined) {
        NSDictionary *iosPayload = @{@"aps": @{@"alert":message.messageText, @"sound": @"default"}, @"calltype":callType,@"type":contentType, @"sender":senderID, @"appointmentID":message.appointmentID};
        
        pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:iosPayload,@"apns", nil];
    }
    
    [self.client publish:msgPayload toChannel:channelID mobilePushPayload:pushPayload storeInHistory:YES withCompletion:^(PNPublishStatus *status) {
        // Check whether request successfully completed or not.
        if (!status.isError) {
            // Message successfully published to specified channel.
        }
        // Request processing failed.
        else {
            // Handle message publish error. Check 'category' property to find out possible issue
            // because of which request did fail.
            [status retry];
        }
    }];
}

#pragma mark - PubNub client delegate methods

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    if(![event.data.presence.uuid isEqualToString:model_manager.profileManager.owner.userID]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(vet.broadcasting_id == %@)",event.data.subscription];
        NSArray *filteredVets = [model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate];
        
        if(filteredVets.count>0) {
            Vet *selectedVet = ((Vet*)[[filteredVets objectAtIndex:0] objectForKey:@"vet"]);
            NSLog(@"didReceivePresenceEvent uuid %@",event.data.presence.uuid);
            if ([event.data.presence.uuid isEqualToString:selectedVet.vetId]) {
                if([event.data.presenceEvent isEqualToString:@"join"]) {
                    selectedVet.vetStatus = @"Online";
                }
                else {
                    selectedVet.vetStatus = @"Offline";
                }
                [model_manager.vetManager filterOnlineVets];
                [model_manager.vetManager filterOfflineVets];
                if ([model_manager.vetManager.vetManagerDelegate respondsToSelector:@selector(notifyVetStatus)])
                {
                    [model_manager.vetManager.vetManagerDelegate notifyVetStatus];
                }
            }
        }
    }
}

// Handle subscription status change.
- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    if (status.category == PNUnexpectedDisconnectCategory) {
        // This event happens when radio / connectivity is lost
    }
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
        
        //check presence on subscribed channels
        for(int i = 0 ; i < status.subscribedChannels.count ; i++) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(vet.broadcasting_id == %@)",[status.subscribedChannels objectAtIndex:i]];
            NSLog(@"%lu",(unsigned long)model_manager.vetManager.arrayVets.count);
            NSArray *filteredUser = [model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate];
            
            if(filteredUser.count>0) {
                Vet *selectedVet = ((Vet*)[[filteredUser objectAtIndex:0] objectForKey:@"vet"]);
                [self getChannelPresence:selectedVet];
            }
        }
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
}


- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    // Handle new message stored in message.data.message
    if(message.data.message) {
        NSDate *receivedMessageDate = [NSDate dateWithTimeIntervalSince1970:[message.data.timetoken doubleValue]/10000000.0];
//        if([receivedMessageDate compare:kAppDelegate.lastForegroundTime] == NSOrderedDescending)
            [kAppDelegate handleInAppNotification:message.data.message];
    }
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,message.data.subscription, message.data.timetoken);
    if([message.data.message valueForKey:@"senderID"]) {
        Message *receivedMessage = [Message new];
        User *sender = [User new];
        sender.userID = [message.data.message valueForKey:@"senderID"];
        sender.name = [message.data.message valueForKey:@"senderName"];
        receivedMessage.sender = sender;
        receivedMessage.messageText = [message.data.message valueForKey:@"text"];
        receivedMessage.time = [NSDate dateWithTimeIntervalSince1970:[message.data.timetoken doubleValue]/10000000.0];
        receivedMessage.messageID = [message.data.message valueForKey:@"messageID"];
        if([[message.data.message valueForKey:@"type"] isEqualToString: @"appointmentRequest"])
            receivedMessage.messageType = MessageTypeAppointmentRequest;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"appointmentAccepted"])
            receivedMessage.messageType = MessageTypeAppointmentRequestAccepted;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"appointmentRejected"])
            receivedMessage.messageType = MessageTypeAppointmentRequestRejected;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"appointmentCancelled"])
            receivedMessage.messageType = MessageTypeAppointmentRequestCancelled;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"appointmentConfirmed"])
            receivedMessage.messageType = MessageTypeAppointmentRequestConfirmed;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"callStarted"])
            receivedMessage.messageType = MessageTypeCallStarted;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"callDeclined"])
            receivedMessage.messageType = MessageTypeCallDeclined;
        else if([[message.data.message valueForKey:@"type"] isEqualToString: @"email"])
            receivedMessage.messageType = MessageTypeEmail;
    }
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,message.data.subscription, message.data.timetoken);
}

@end
