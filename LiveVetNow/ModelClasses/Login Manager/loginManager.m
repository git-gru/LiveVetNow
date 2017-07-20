//
//  loginManager.m
//

#import "loginManager.h"
#import "Appdelegate.h"
#import "Constants.h"

@implementation loginManager

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)login:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"login" requestType:RequestTypePost timeOut:180 includeHeader:NO paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"]boolValue];
        
        if ((statusCode==200) && (success)) {
            [self setLoginData:json withCompletionBlock:^(BOOL complete) {
                if (complete) {
                    completionBlock(true,message);
                }
            }];
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

-(void)setLoginData:(id)json withCompletionBlock:(void (^)(BOOL))completionBlock {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"autoLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([[json objectForKey:@"data"] objectForKey:@"user_type"]) {
            if ([[[json objectForKey:@"data"] objectForKey:@"user_type"] isEqualToString:@"user"]) {
                kAppDelegate.isVet = NO;
            }
            else {
               
                kAppDelegate.isVet = YES;
            }
            //If Vet
            if (kAppDelegate.isVet) {
                if ([json objectForKey:@"data"]) {
                    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: [Vet class]];
                    Vet *currentVet = [parser parseDictionary:[json objectForKey:@"data"]];
                    model_manager.profileManager.ownerVet = currentVet;
                    if ([[json objectForKey:@"data"] objectForKey:@"userid"]) {
                        model_manager.profileManager.ownerVet.vetId = [NSString stringWithFormat:@"%@",[[json objectForKey:@"data"] objectForKey:@"userid"]];
                    }
                    if ([[json objectForKey:@"data"] objectForKey:@"image_url"]) {
                       
                        model_manager.profileManager.ownerVet.image_url = [NSString stringWithFormat:@"%@%@",[[json objectForKey:@"data"] objectForKey:@"host"],[[json objectForKey:@"data"] objectForKey:@"image_url"]];

                    }
                }
            }
            //If Client
            else {
                if ([[json objectForKey:@"data"] objectForKey:@"image_url"]) {
                    
                    model_manager.profileManager.owner.profilePicUrl = [NSString stringWithFormat:@"%@%@",[[json objectForKey:@"data"] objectForKey:@"host"],[[json objectForKey:@"data"] objectForKey:@"image_url"]];
                }
                if ([[json objectForKey:@"data"] objectForKey:@"name"]) {
                    model_manager.profileManager.owner.name = [[json objectForKey:@"data"] objectForKey:@"name"];
                }
                if ([[json objectForKey:@"data"] objectForKey:@"email"]) {
                    model_manager.profileManager.owner.email = [[json objectForKey:@"data"] objectForKey:@"email"];
                }
                if ([[json objectForKey:@"data"] objectForKey:@"userid"]) {
                    model_manager.profileManager.owner.userID = [NSString stringWithFormat:@"%@",[[json objectForKey:@"data"] objectForKey:@"userid"]];
                }
            }
        }
        self.accessToken = [[json objectForKey:@"extra_params"] objectForKey:@"token"];
    
    NSDictionary *jsonDict =(NSDictionary*) json;
        [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"autoLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    completionBlock(true);
}

-(void)registerUser:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"register" requestType:RequestTypePost timeOut:180 includeHeader:NO paramsDict:dict onCompletion:^(long statusCode,id json) {
        NSString *message = [json objectForKey:@"message"];
        
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success))
        {
            
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

-(void)logout {

}

-(void)fetchLocationswithCompletionBlock:(void (^)(BOOL,NSArray*))completionBlock
{
    
    [model_manager.request_Manager requestWithPath:@"get_states" requestType:RequestTypeGet timeOut:180 includeHeader:NO paramsDict:nil onCompletion:^(long statusCode,id json)
     
     {
         
         BOOL success = [[json objectForKey:@"status"] boolValue];
         
         if ((statusCode==200) && (success))
         {
             NSArray *citiesArray = (NSArray*)[json objectForKey:@"data"];
             
             
             completionBlock(true,citiesArray);
             
         }
         else
         {
             if (statusCode == 400) {
                 completionBlock(false,[[NSArray alloc]init]);
             }
             else if (statusCode == 401) {
                 completionBlock(false,[[NSArray alloc]init]);
             }
             else if (statusCode == 500)
             {
                 
                 completionBlock(false,[[NSArray alloc]init]);
                 
             }
             
             
         }
     }];
}
//NSString *imageBase64 = [Base64 encode:UIImageJPEGRepresentation(imgViewProfile.image, 0.1f)];
//    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]initWithObjectsAndKeys:imageBase64,@"imgdata",nil];
//{
//    Image : sdfsdlklkdsjsldkjfdkjsdslkd //base64 encoded string
//Vet_detail_id: 3 //if uploading image of pet else not req.
//}

-(void)uploadImage:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*,NSString*))completionBlock {
    [model_manager.request_Manager requestWithPath:@"update_image" requestType:RequestTypePost timeOut:180 includeHeader:YES paramsDict:dict onCompletion:^(long statusCode,id json) {
        
        NSString *message = [json objectForKey:@"message"];
        BOOL success = [[json objectForKey:@"status"] boolValue];
        
        if ((statusCode==200) && (success)) {
            if ([json objectForKey:@"data"]) {
                if ([[json objectForKey:@"data"] objectForKey:@"image_url"]) {
                    completionBlock(true,message,[[json objectForKey:@"data"] objectForKey:@"image_url"]);
                }
            }
        }
        else {
            if (statusCode == 400) {
                completionBlock(false,message,@"");
            }
            else if (statusCode == 401) {
                completionBlock(false,message,@"");
            }
            else if (statusCode == 500) {
                completionBlock(false,message,@"");
            }
        }
    }];
}

@end
