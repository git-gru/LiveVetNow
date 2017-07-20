//
//  EmailManager.m
//  LiveVetNow
//
//  Created by apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "EmailManager.h"
#import "Constants.h"
#import "Email.h"

@implementation EmailManager

- (id)init {
    self = [super init];
    if (self) {
        self.arrayEmails = [NSMutableArray new];
    }
    return self;
}

-(void)sendEmail:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"send_messages" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
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

-(void)getEmails:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    NSString *tempID;
    //if (kAppDelegate.isVet)
     //   tempID = model_manager.profileManager.ownerVet.vetId;
   // else
     //   tempID = model_manager.profileManager.owner.userID;
    
    [model_manager.request_Manager requestWithPath:[NSString stringWithFormat: @"get_messages"] requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                [self.arrayEmails removeAllObjects];
                NSMutableArray *arrEmails = [json objectForKey:@"data"];
                for (id object in arrEmails) {
                    // do something with object
                    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Email class]];
                    Email *currentEmail = [parser parseDictionary:object];
                    [self.arrayEmails addObject:currentEmail];
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

@end
