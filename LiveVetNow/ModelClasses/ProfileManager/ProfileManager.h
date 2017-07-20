//
//  ProfileManager.h
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Vet.h"

@interface ProfileManager : NSObject

@property (strong,nonatomic) User *owner;
@property (strong,nonatomic) Vet *ownerVet;

-(void)editDetails:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)getDoctorSpecialities:(void (^)(BOOL,NSArray*))completionBlock ;
-(void)changePasswordWithParams:(NSDictionary*)dict handler:(void (^)(BOOL,NSString*))completionBlock;
-(void)upgradeDoctorWithParams:(NSDictionary*)dict handler:(void (^)(BOOL,NSString*))completionBlock ;
-(void)upgradeDoctorPaypalIDWithParams:(NSDictionary*)dict handler:(void (^)(BOOL,NSString*))completionBlock ;
-(void)updateAvailabilityStatus:(NSString*)status WithHandler:(void (^)(BOOL,NSString*))completionBlock;

@end
