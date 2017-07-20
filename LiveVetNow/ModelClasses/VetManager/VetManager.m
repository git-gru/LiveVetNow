//
//  VetManager.m
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "VetManager.h"
#import "Constants.h"
#import "Vet.h"

@implementation VetManager

@synthesize vetManagerDelegate;

- (id)init {
    self = [super init];
    if (self) {
        self.arrayVets = [NSMutableArray new];
        self.arrayVetsChannel = [NSMutableArray new];
    }
    return self;
}

-(void)getEmergencyVets:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock
{
   
    [model_manager.request_Manager requestWithPath:@"get_30_min_doctor" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json) {
       
        NSString *message = [json objectForKey:@"message"];
        
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayVets removeAllObjects];
                [self.arrayVetsChannel removeAllObjects];
                if ([[json objectForKey:@"data"] objectForKey:@"recommended_doctors"]) {
                    NSMutableArray *arrRecommendedVets = [[json objectForKey:@"data"] objectForKey:@"recommended_doctors"];
                    for (id object in arrRecommendedVets) {
                        // do something with object
                        DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Vet class]];
                        Vet *currentVet = [parser parseDictionary:object];
                        if ([object objectForKey:@"id"]) {
                            currentVet.vetId = [NSString stringWithFormat:@"%@",[object objectForKey:@"id"]];
                        }
                        NSMutableDictionary *dict;
                        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentVet,@"vet",@"true",@"isRecommended", nil];
                        [self.arrayVets addObject:dict];
                    }
                }
                if ([[json objectForKey:@"data"] objectForKey:@"regular_doctors"]) {
                    NSMutableArray *arrOtherVets  = [[json objectForKey:@"data"] objectForKey:@"regular_doctors"];
                    for (id object in arrOtherVets) {
                        // do something with object
                        DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Vet class]];
                        Vet *currentVet = [parser parseDictionary:object];
                        if ([object objectForKey:@"id"]) {
                            currentVet.vetId = [NSString stringWithFormat:@"%@",[object objectForKey:@"id"]];
                        }
                        NSMutableDictionary *dict;
                        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentVet,@"vet",@"false",@"isRecommended", nil];
                        [self.arrayVets addObject:dict];
                    }
                }
                [self getVetsChannel];
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

-(void)getVets:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"get_doctor" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json) {
        NSString *message = [json objectForKey:@"message"];
        
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayVets removeAllObjects];
                [self.arrayVetsChannel removeAllObjects];
                if ([[json objectForKey:@"data"] objectForKey:@"recommended_doctors"]) {
                    NSMutableArray *arrRecommendedVets = [[json objectForKey:@"data"] objectForKey:@"recommended_doctors"];
                    for (id object in arrRecommendedVets) {
                        // do something with object
                        DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Vet class]];
                        Vet *currentVet = [parser parseDictionary:object];
                        if ([object objectForKey:@"id"]) {
                            currentVet.vetId = [NSString stringWithFormat:@"%@",[object objectForKey:@"id"]];
                        }
                        NSMutableDictionary *dict;
                        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentVet,@"vet",@"true",@"isRecommended", nil];
                        [self.arrayVets addObject:dict];
                    }
                }
                if ([[json objectForKey:@"data"] objectForKey:@"regular_doctors"]) {
                    NSMutableArray *arrOtherVets  = [[json objectForKey:@"data"] objectForKey:@"regular_doctors"];
                    for (id object in arrOtherVets) {
                        // do something with object
                        DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Vet class]];
                        Vet *currentVet = [parser parseDictionary:object];
                        if ([object objectForKey:@"id"]) {
                            currentVet.vetId = [NSString stringWithFormat:@"%@",[object objectForKey:@"id"]];
                        }

                        NSMutableDictionary *dict;
                        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentVet,@"vet",@"false",@"isRecommended", nil];
                        [self.arrayVets addObject:dict];
                    }
                }
                [self getVetsChannel];
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

- (void)filterOfflineVets {
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(vet.vetStatus== %@)",@"Offline"];
    if ([self.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
        NSMutableArray *arrayVetsOnline = [[self.arrayVets filteredArrayUsingPredicate:predicate] mutableCopy];
        
        NSPredicate *predicateRecommended = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
        if ([arrayVetsOnline filteredArrayUsingPredicate:predicateRecommended].count>0) {
            self.arrayVetsOfflineRecommended = [[arrayVetsOnline filteredArrayUsingPredicate:predicateRecommended] mutableCopy];
        }
        
        NSPredicate *predicateOther = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
        if ([arrayVetsOnline filteredArrayUsingPredicate:predicateOther].count>0) {
            self.arrayVetsOfflineOthers = [[arrayVetsOnline filteredArrayUsingPredicate:predicateOther] mutableCopy];
        }
    }
}

- (void)filterOnlineVets {
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(vet.vetStatus== %@)",@"Online"];
    if ([self.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
        NSMutableArray *arrayVetsOnline = [[self.arrayVets filteredArrayUsingPredicate:predicate] mutableCopy];
        
        NSPredicate *predicateRecommended = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
        if ([arrayVetsOnline filteredArrayUsingPredicate:predicateRecommended].count>0) {
            self.arrayVetsOnlineRecommended = [[arrayVetsOnline filteredArrayUsingPredicate:predicateRecommended] mutableCopy];
        }
        
        NSPredicate *predicateOther = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
        if ([arrayVetsOnline filteredArrayUsingPredicate:predicateOther].count>0) {
            self.arrayVetsOnlineOthers = [[arrayVetsOnline filteredArrayUsingPredicate:predicateOther] mutableCopy];
        }
    }
}

- (void)getVetsChannel {
    for (id object in self.arrayVets) {
        // do something with object
        Vet *currentVet = [object valueForKey:@"vet"];
        [self.arrayVetsChannel addObject:currentVet.broadcasting_id];
    }
}


-(void)inviteVet:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"invite_doctor" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
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


@end
