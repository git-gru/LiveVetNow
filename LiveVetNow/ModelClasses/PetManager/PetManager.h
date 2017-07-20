//
//  PetManager.h
//  LiveVetNow
//
//  Created by apple on 31/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PetManager : NSObject

@property(nonatomic,retain) NSMutableArray *arrayPets;

-(void)getPets:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)getPetTypeListWithCompletionBlock:(void (^)(BOOL,NSArray*))completionBlock;
-(void)addPet:(NSDictionary *)dict withCompletionBlock:(void (^)(NSString*,NSString*))completionBlock ;
-(void)uploadPetImage:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock ;
-(void)deletePet:(NSString *)pedID withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock ;

    

@end
