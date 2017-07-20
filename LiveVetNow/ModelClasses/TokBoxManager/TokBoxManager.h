//
//  TokBoxManager.h
//  LiveVetNow
//
//  Created by Apple on 23/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokBoxManager : NSObject

-(void)fetchTokBoxSessionWithAppointmentID:(NSString*)appntmntID withCompletionBlock:(void (^)(BOOL,NSDictionary*))completionBlock;


@end
