//
//  PubnubChatClient.h
//

#import "ChatVendorI.h"
#import <Foundation/Foundation.h>
//#import <CommonCrypto/CommonDigest.h>
#import "PubNub.h"


@interface PubnubChatClient : ChatVendorI {
    
}

@property (nonatomic,strong) NSData *devicePushToken;
-(void)enablePushNotification:(NSString*)channel;
-(void)disablePushNotification:(NSString*)channel;

@end
