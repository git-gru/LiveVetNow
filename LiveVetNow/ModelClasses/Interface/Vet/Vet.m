//
//  Vet.m
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "Vet.h"

@implementation Vet

- (id)init {
    self = [super init];
    if(self) {
        // Work your initialising magic here as you normally would
        self.vetId = @"";
        self.broadcasting_id = @"";
        self.name = @"Doctor Doctor";
        self.overview = @"";
        self.image_url = @"";
        self.vetStatus = @"Offline";
        self.state = @"New York";
        self.speciality_name = @"Dog, Cat";
    }
    return self;
}

@end
