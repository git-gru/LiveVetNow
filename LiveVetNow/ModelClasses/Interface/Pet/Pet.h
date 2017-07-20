//
//  Pet.h
//  LiveVetNow
//
//  Created by apple on 30/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pet : NSObject

@property(nonatomic,retain)NSString *pet_id;
@property(nonatomic,retain)NSString *pet_name;
@property(nonatomic,retain)NSString *pet_type;
@property(nonatomic,retain)NSString *pet_image_url;
@property(nonatomic,retain)NSString *pet_age;
@property(nonatomic,retain)NSString *pet_sex;
@property(nonatomic,retain)NSString *pet_host;


@end
