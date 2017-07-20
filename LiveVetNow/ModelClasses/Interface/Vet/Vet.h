//
//  Vet.h
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vet : NSObject

@property(nonatomic,retain)NSString *vetId;
@property(nonatomic,retain)NSString *broadcasting_id;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *state;
@property(nonatomic,retain)NSString *speciality_name;
@property(nonatomic,retain)NSString *overview;
@property(nonatomic,retain)NSString *image_url;
@property(nonatomic,retain)NSString *vetStatus;
@property (strong,nonatomic) NSString *email;
@property (strong,nonatomic) NSString *host;
@property(strong,nonatomic)NSDictionary *review_details;
@end
