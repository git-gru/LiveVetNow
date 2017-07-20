//
//  PetManager.m
//  LiveVetNow
//
//  Created by apple on 31/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "PetManager.h"
#import "Constants.h"
#import "Pet.h"

@implementation PetManager

- (id)init {
    self = [super init];
    if (self) {
        self.arrayPets = [NSMutableArray new];
    }
    return self;
}

-(void)uploadPetImage:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"update_image" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            
            if ([json objectForKey:@"data"]) {
                
                if (!kAppDelegate.isVet)
                {
                model_manager.profileManager.owner.profilePicUrl = [[json objectForKey:@"data"] objectForKey:@"image_url"];
                }
                else{
                    
                    model_manager.profileManager.ownerVet.image_url = [[json objectForKey:@"data"] objectForKey:@"image_url"];

                }
                completionBlock(true,message);
            }
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)getPetTypeListWithCompletionBlock:(void (^)(BOOL,NSArray*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"pet_type_list" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
                NSArray *petTypes = (NSArray*)[json objectForKey:@"data"];
                completionBlock(true,petTypes);
                
            }
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,[[NSArray alloc]init]);
            }
            else if (statusCode == 401) {
                completionBlock(false,[[NSArray alloc]init]);
            }
            else if (statusCode == 500) {
                completionBlock(false,[[NSArray alloc]init]);
            }
        }
    }];
}

-(void)addPet:(NSDictionary *)dict withCompletionBlock:(void (^)(NSString*,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"add_pet" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
            }
            completionBlock([[json objectForKey:@"data"] objectForKey:@"id"],message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(@"",message);
            }
            else if (statusCode == 401) {
                completionBlock(@"",message);
            }
            else if (statusCode == 500) {
                completionBlock(@"",message);
            }
        }
    }];
}

-(void)getPets:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"find_pet" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayPets removeAllObjects];
                NSMutableArray *arrPets = [json objectForKey:@"data"];
                for (id object in arrPets) {
                    // do something with object
                    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Pet class]];
                    Pet *currentPet = [parser parseDictionary:object];
                    [self.arrayPets addObject:currentPet];
                }
            }
            completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}


-(void)deletePet:(NSString *)pedID withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:[NSString stringWithFormat:@"delete_pet/%@",pedID] requestType:RequestTypeDelete timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json) {
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
                      completionBlock(true,message);
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message);
            }
            else if (statusCode == 401) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}


@end
