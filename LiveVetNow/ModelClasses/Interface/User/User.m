//
//  User.m
//  LiveVetNow
//
//  Created by apple on 17/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userID;
@synthesize email;
@synthesize name;
@synthesize profilePicUrl;
    
- (id)init {
    self = [super init];
    if(self) {
        // Work your initialising magic here as you normally would
        self.userID=@"";
        self.email=@"";
        self.name=@"";
        self.profilePicUrl=@"";
    }
    return self;
}

@end
