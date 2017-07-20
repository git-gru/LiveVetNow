//
//  Message.h
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(int, MessageType) {
    MessageTypeAppointmentRequest,
    MessageTypeAppointmentRequestAccepted,
    MessageTypeAppointmentRequestRejected,
    MessageTypeAppointmentRequestCancelled,
    MessageTypeEmail,
    MessageTypeAppointmentRequestConfirmed,
    MessageTypeCallStarted,
    MessageTypeCallDeclined
};

@interface Message : NSObject

@property(nonatomic,retain)NSString *messageID;
@property(assign,nonatomic)MessageType messageType;
@property(nonatomic,retain)NSString *messageText;
@property(nonatomic,retain)NSDate *time;
@property(nonatomic,retain)User *sender;
@property(nonatomic,retain)NSString *appointmentID;

@end
