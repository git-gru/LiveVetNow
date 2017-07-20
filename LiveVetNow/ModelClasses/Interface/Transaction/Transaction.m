//
//  Transaction.m
//  LiveVetNow
//
//  Created by apple on 03/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

- (id)init {
    self = [super init];
    if(self) {
        // Work your initialising magic here as you normally would
        self.apt_datetime = @"";
        self.txn_id = @"";
        self.txn_date = @"";
        self.txn_amount = @"";
        self.doctor_name = @"";
        self.user_name = @"";
        self.currency = @"";

    }
    return self;
}

@end
