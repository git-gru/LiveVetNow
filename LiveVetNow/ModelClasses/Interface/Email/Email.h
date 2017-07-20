//
//  Email.h
//  LiveVetNow
//
//  Created by apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Email : NSObject

@property (strong,nonatomic) NSString *id;
@property (strong,nonatomic) NSString *msg_from;
@property (strong,nonatomic) NSString *msg_from_name;
@property (strong,nonatomic) NSString *from_image_url;
@property (strong,nonatomic) NSString *to_image_url;

@property (strong,nonatomic) NSString *msg_to_name;
@property (strong,nonatomic) NSString *message;
@property (strong,nonatomic) NSString *msg_to;

@property (strong,nonatomic) NSString *updated_at;
@property (strong,nonatomic) NSString *created_at;

@end
