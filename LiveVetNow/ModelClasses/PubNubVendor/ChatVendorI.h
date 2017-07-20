//
//  ChatVendorI.h
//

#import <Foundation/Foundation.h>
#import "Vet.h"
#import "Message.h"

@interface ChatVendorI : NSObject {
    
}

@property(assign,nonatomic) BOOL isClientInitialized;

-(BOOL)initChatClient:(NSString*)userID broadcast_id:(NSString*)broadcastingID;
-(BOOL)destroyChatClient;

-(BOOL)subscribeToChannels:(NSArray*)channels presenceRequired:(BOOL)presence;
-(BOOL)unSubscribeToChannels:(NSArray*)channels;


-(void)sendMessageViaPubNub:(Message*)message toChannel:(NSString*)channelID name:(NSString*)senderName userId:(NSString*)senderID typeOfCall:(NSString*)callType;
-(void)getChannelPresence:(Vet*)vet;

@end
