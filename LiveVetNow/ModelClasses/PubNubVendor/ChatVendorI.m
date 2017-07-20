//
//  ChatVendorI.m
//


#import "ChatVendorI.h"

@implementation ChatVendorI
@synthesize isClientInitialized;

-(BOOL)initChatClient:(NSString*)userID broadcast_id:(NSString*)broadcastingID {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
    return YES;
}

-(BOOL)destroyChatClient {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return YES;
}


-(BOOL)subscribeToChannels:(NSArray*)channels presenceRequired:(BOOL)presence {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return YES;
}

-(BOOL)unSubscribeToChannels:(NSArray*)channels {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return YES;
}

-(void)sendMessageViaPubNub:(Message*)message toChannel:(NSString*)channelID name:(NSString*)senderName userId:(NSString*)senderID typeOfCall:(NSString*)callType {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void)getChannelPresence:(Vet*)vet {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


@end
