//
//  TokBoxManager.m
//  LiveVetNow
//
//  Created by Apple on 23/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "TokBoxManager.h"
#import "Constants.h"

@implementation TokBoxManager

-(void)fetchTokBoxSessionWithAppointmentID:(NSString*)appntmntID withCompletionBlock:(void (^)(BOOL,NSDictionary*))completionBlock
{
    
    [model_manager.request_Manager requestWithPath:[NSString stringWithFormat:@"get_tokbox_details/%@",appntmntID] requestType:RequestTypeGet timeOut:180 includeHeader:YES paramsDict:nil onCompletion:^(long statusCode,id json)
     
     {
         
         BOOL success = [[json objectForKey:@"status"] boolValue];
         
         if ((statusCode==200) && (success))
         {
             NSDictionary *sessionDict = (NSDictionary*)[json objectForKey:@"data"];
             
             completionBlock(true,sessionDict);
             
         }
         else
         {
             if (statusCode == 400)
             {
                 
                 completionBlock(false,[[NSDictionary alloc]init]);
                 
             }
             else if (statusCode == 401)
             {
                 
                 
                 completionBlock(false,[[NSDictionary alloc]init]);
                 
             }
             else if (statusCode == 500)
             {
                 
                 completionBlock(false,[[NSDictionary alloc]init]);
                 
             }
             
             
         }
     }];
    
}


@end
