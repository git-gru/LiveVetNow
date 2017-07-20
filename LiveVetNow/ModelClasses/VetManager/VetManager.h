//
//  VetManager.h
//  LiveVetNow
//
//  Created by apple on 18/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol PubPresenceDelegate <NSObject>

@optional
-(void)notifyVetStatus;
@end

@interface VetManager : NSObject<PubPresenceDelegate>


@property(weak,nonatomic) id<PubPresenceDelegate> vetManagerDelegate;
@property(nonatomic,retain) NSMutableArray *arrayVets;
@property(nonatomic,retain) NSMutableArray *arrayVetsOnlineRecommended;
@property(nonatomic,retain) NSMutableArray *arrayVetsOnlineOthers;
@property(nonatomic,retain) NSMutableArray *arrayVetsOfflineRecommended;
@property(nonatomic,retain) NSMutableArray *arrayVetsOfflineOthers;
@property(nonatomic,retain) NSMutableArray *arrayVetsChannel;

-(void)getVets:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)getEmergencyVets:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)inviteVet:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
- (void)filterOfflineVets;
- (void)filterOnlineVets;

@end
