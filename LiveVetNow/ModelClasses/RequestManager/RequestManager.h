//
//  RequestManager.h
//  Voice
//
//  Created by Apple on 7/8/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkReachabilityManager.h"
//#import "Reachability.h"


typedef enum
{
    RequestTypePost     = 0,
    RequestTypeGet      = 1,
    RequestTypeDelete   = 2,
    RequestTypePut      = 3
} RequestType;

@interface RequestManager : NSObject

@property (nonatomic,assign) RequestType requestType;
@property (nonatomic,assign) BOOL        isInternetReachable;
typedef   void (^JSONResponseBlock)(long statusCode,NSDictionary *json);

-(void) requestWithPath:(NSString *)strPath
            requestType:(RequestType)type
                timeOut:(NSInteger)time
          includeHeader:(BOOL)includeHeaders
             paramsDict:(NSDictionary *)parameterDictionary onCompletion:(JSONResponseBlock)completionBlock;
@end
