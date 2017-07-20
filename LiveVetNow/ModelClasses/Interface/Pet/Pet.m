//
//  Pet.m
//  LiveVetNow
//
//  Created by apple on 30/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "Pet.h"

@implementation Pet

- (id)init {
    self = [super init];
    if(self) {
        // Work your initialising magic here as you normally would
        self.pet_id = @"";
        self.pet_name = @"";
        self.pet_image_url = @"";
        self.pet_type = @"";
        self.pet_age = @"";
        self.pet_sex = @"";
    }
    return self;
}

@end
