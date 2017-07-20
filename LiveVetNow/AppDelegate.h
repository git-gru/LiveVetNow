//
//  AppDelegate.h
//  LiveVetNow
//
//  Created by Apple on 10/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,UIGestureRecognizerDelegate> {
    UIView *inAppNotificationView;
    UIView *viewToSwipe;
    UISwipeGestureRecognizer *swipeGesture;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (assign, nonatomic) BOOL isInternetReachable;
@property(strong,nonatomic) UINavigationController *navigationController;
@property (assign, nonatomic) BOOL isVet;
@property (strong, nonatomic) NSDictionary *pushPayload;
@property (assign, nonatomic) BOOL isCall;
@property (assign, nonatomic) BOOL isFromPushNotification;
@property (strong, nonatomic) NSDate *lastForegroundTime;
@property(nonatomic,strong) AVAudioPlayer *inAppNotificationSound;

-(void)saveContext;
-(void)logOut;
-(UIAlertController*)showAlert:(NSString*)string;
-(void)showNotificationView:(NSString *)message;
- (void)handleInAppNotification:(NSDictionary *)userInfo;


@end

