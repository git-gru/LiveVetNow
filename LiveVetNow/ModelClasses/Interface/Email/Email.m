//
//  Email.m
//  LiveVetNow
//
//  Created by apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "Email.h"

@implementation Email

- (id)init {
    self = [super init];
    if(self) {
        // Work your initialising magic here as you normally would
        self.id = @"";
        self.msg_to_name = @"";
        self.msg_from = @"";
        self.message = @"";
        self.created_at = @"";
        self.updated_at = @"";
        self.msg_from_name = @"";
        self.from_image_url = @"";
    }
    return self;
}

@end
