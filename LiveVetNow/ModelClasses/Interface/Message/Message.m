//
//  Message.m
//

#import "Message.h"

@implementation Message

- (id)init {
    self = [super init];
    
    if(self) {
        // Work your initialising magic here as you normally would
        self.messageID = @"";
        self.messageText = @"";
        self.sender = [User new];
        self.appointmentID = @"";
    }
    return self;
}

@end
