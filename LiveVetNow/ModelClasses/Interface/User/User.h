//
//  User.h
//  LiveVetNow
//
//  Created by apple on 17/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

// User Properties
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSString *email;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *profilePicUrl;

@end
