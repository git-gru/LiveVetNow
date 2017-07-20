//
//  ProfileManager.m
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "ProfileManager.h"
#import "Constants.h"
#import "User.h"
#import "Vet.h"

@implementation ProfileManager

- (id)init {
    self = [super init];
    if (self) {
        // initialize the owner object
        if (kAppDelegate.isVet) {
            self.ownerVet = [Vet new];
        }
        else {
            self.owner=[User new];
        }
    }
    return self;
}


//{
//name: “manish”,
//about_me: “sdfsdfsdfsdfsf”,
//speciality_id: 1,// required in case of doctor only
//location_id:1 // required in case of doctor only
//}


-(void)editDetails:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"edit_details" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
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
            else if (statusCode == 422) {
                completionBlock(false,message);
            }

            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
}

-(void)getDoctorSpecialities:(void (^)(BOOL,NSArray*))completionBlock {
   
    [model_manager.request_Manager requestWithPath:@"get_speciality" requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
                
                
                NSArray *specialities = (NSArray*)[json objectForKey:@"data"];
                completionBlock(true,specialities);
                
            }
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,[[NSArray alloc]init]);
            }
            else if (statusCode == 401) {
                completionBlock(false,[[NSArray alloc]init]);
            }
            else if (statusCode == 422) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,[[NSArray alloc]init]);
            }
        }
    }];
}


-(void)changePasswordWithParams:(NSDictionary*)dict handler:(void (^)(BOOL,NSString*))completionBlock {
    
    
    [model_manager.request_Manager requestWithPath:@"change_password" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
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
            else if (statusCode == 422) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];

}

-(void)upgradeDoctorWithParams:(NSDictionary*)dict handler:(void (^)(BOOL,NSString*))completionBlock {
    
    
    [model_manager.request_Manager requestWithPath:@"upgrade_doctor" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
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
            else if (statusCode == 422) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
    
}

-(void)upgradeDoctorPaypalIDWithParams:(NSDictionary*)dict handler:(void (^)(BOOL,NSString*))completionBlock {
    
    
    [model_manager.request_Manager requestWithPath:@"update_paypal" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
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
            else if (statusCode == 422) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
    
}

-(void)updateAvailabilityStatus:(NSString*)status WithHandler:(void (^)(BOOL,NSString*))completionBlock {
    
    
    [model_manager.request_Manager requestWithPath:[NSString stringWithFormat:@"my_status/%@",status]  requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                
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
            else if (statusCode == 422) {
                completionBlock(false,message);
            }
            else if (statusCode == 500) {
                completionBlock(false,message);
            }
        }
    }];
    
}






@end
