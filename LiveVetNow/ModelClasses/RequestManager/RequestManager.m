//
//  RequestManager.m
//  Voice
//
//  Created by Apple on 7/8/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "RequestManager.h"
#import "AFHTTPSessionManager.h"
#include "Constants.h"
@implementation RequestManager
{
    //    Reachability *_internetReachable;
}
@synthesize requestType;
@synthesize isInternetReachable;

#pragma mark - Send asynchronous request
#pragma mark - Return URL Request
// Returns an instance of NSMutableURLRequest with specified parameters.
-(void) requestWithPath:(NSString *)strPath
            requestType:(RequestType)type
                timeOut:(NSInteger)time
          includeHeader:(BOOL)includeHeaders
             paramsDict:(NSDictionary *)parameterDictionary onCompletion:(JSONResponseBlock)completionBlock
{
    
    requestType=type;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    if (includeHeaders) {
        NSString *token = [NSString stringWithFormat:@"Bearer %@",model_manager.login_Manager.accessToken];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,strPath];
    if (requestType == RequestTypeGet) {
        [manager GET:strUrl parameters:parameterDictionary progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            [self handleResponse:task withResponseObject:responseObject withError:nil withBlock:completionBlock];
            
        } failure:^(NSURLSessionTask *task, NSError *error) {
        
            [self handleResponse:task withResponseObject:nil withError:error withBlock:completionBlock];
        
        }];
    }
    else if (requestType == RequestTypePost)
    {
        [manager POST:strUrl parameters:parameterDictionary progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            [self handleResponse:task withResponseObject:responseObject withError:nil withBlock:completionBlock];

            
        } failure:^(NSURLSessionTask *task, NSError *error) {
            
            
           
            [self handleResponse:task withResponseObject:nil withError:error withBlock:completionBlock];
  }];
        
    }
    else if(requestType == RequestTypePut)
    {
        
        [manager PUT:strUrl parameters:parameterDictionary success:^(NSURLSessionTask *task, id responseObject) {
            
            [self handleResponse:task withResponseObject:responseObject withError:nil withBlock:completionBlock];

            
        }  failure:^(NSURLSessionTask *task, NSError *error) {
           
            [self handleResponse:task withResponseObject:nil withError:error withBlock:completionBlock];
        }];
    }
    else if(requestType == RequestTypeDelete)
    {
        [manager DELETE:strUrl parameters:parameterDictionary success:^(NSURLSessionTask *task, id responseObject) {
           
            [self handleResponse:task withResponseObject:responseObject withError:nil withBlock:completionBlock];
        
        }  failure:^(NSURLSessionTask *task, NSError *error) {
           
            [self handleResponse:task withResponseObject:nil withError:error withBlock:completionBlock];

        }];
        
    }
    
}

-(void)handleResponse:(NSURLSessionTask*)task withResponseObject:(id)responseObject withError:(NSError*)error withBlock:(JSONResponseBlock)completionBlock
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;

    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
       
        NSNumber *statusCode = [NSNumber numberWithLong:(long)httpResponse.statusCode];
        if (error == nil)
        {
       
        NSError *errorJson;
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJson];
        completionBlock(statusCode.integerValue,responseDict);
        
        }
        else {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"Failure error serialised - %@",serializedData);
            if (statusCode.integerValue == 401) {
                [kAppDelegate logOut];
            }
            completionBlock(statusCode.integerValue,serializedData);
        }
    }
}

@end
