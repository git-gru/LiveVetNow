//
//  EmailManager.h
//  LiveVetNow
//
//  Created by apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailManager : NSObject

@property(nonatomic,retain) NSMutableArray *arrayEmails;

-(void)getEmails:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;

-(void)sendEmail:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;

@end
