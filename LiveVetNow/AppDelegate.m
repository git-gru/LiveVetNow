//
//  AppDelegate.m
//  LiveVetNow
//
//  Created by Apple on 10/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "PayPalMobile.h"
#import "Constants.h"

#define kLVNTextTag 1
#define kMessageTextTag 2
#define kBtnRejectCallTag 4
#define kBtnAcceptCallTag 5
#define kTapView 10

@interface AppDelegate () {
    int time;
    NSTimer *timer;
}

@end


@implementation AppDelegate
@synthesize isInternetReachable;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self createInAppNotificationView];
    
    //    self.inAppNotificationSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                                 pathForResource:@"phone_ringing"                                                                                           ofType:@"mp3"]] error:nil];
    //
    //    self.inAppNotificationSound.volume = 0.7;
    //    self.inAppNotificationSound.numberOfLoops = -1;
    // [self.inAppNotificationSound prepareToPlay];
    
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginViewController *loginObj = [login instantiateViewControllerWithIdentifier:@"LoginVC"];
    
    self.navigationController = [[UINavigationController alloc]initWithRootViewController:loginObj];
    self.navigationController.navigationBarHidden = true;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    //check if app opened from push notification
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        //app opened from push notification
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (userInfo != nil) {
            self.isFromPushNotification = YES;
            self.pushPayload = userInfo;
            NSString *pushType = [self.pushPayload objectForKey:@"type"];
            if (![pushType isEqualToString:@"callStarted"]) {
            NSString *appointmentId = [userInfo objectForKey:@"appointmentID"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"callStarted" object:appointmentId];
            }
        }
    }
    else {
        self.isFromPushNotification = NO;
    }
    
    // CGFloat width = [Utilities mainScreenWidth];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if( !error ){
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }];
    
    
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                           PayPalEnvironmentSandbox : @"ASINc0Lq8rp7AslchAVQuCA6Yy-nRY3AN9at99neeY8WdBhdgXSs2tHa0slhAoxNbopiyPjC_fNfae2i"}];
    
    return YES;
}

-(void)logOut {
    [model_manager.chatVendor destroyChatClient];
    [self.navigationController popToRootViewControllerAnimated:true];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"autoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (UIAlertController*)showAlert:(NSString*)string {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    return alert;
}

- (void)handleInAppNotification:(NSDictionary *)userInfo {
    UILabel * lblLVN = [inAppNotificationView viewWithTag:kLVNTextTag];
    lblLVN.frame = CGRectMake(12, 18, 100, 21);
    UIView *clearTapView = [inAppNotificationView viewWithTag:kTapView];
    CGRect frameTap = clearTapView.frame;
    frameTap.size.width = kAppDelegate.window.frame.size.width;
    clearTapView.frame = frameTap;
    
    [inAppNotificationView bringSubviewToFront:clearTapView];
    if(![[userInfo objectForKey:@"senderID"] isEqualToString:model_manager.profileManager.owner.userID]) {
        self.pushPayload = userInfo;
    }
    [model_manager.notificationManager notificationManagerShowInAppNotification:userInfo];
}

-(void)createInAppNotificationView {
    //create inAppNotificationView
    inAppNotificationView=[[UIView alloc] init];
    inAppNotificationView.backgroundColor = [UIColor blueColor];
    
    swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeInApp)];
    swipeGesture.direction=UISwipeGestureRecognizerDirectionUp;
    //[inAppNotificationView addGestureRecognizer:swipeGesture];
    
    UILabel * lblLVN = [[UILabel alloc]initWithFrame:CGRectMake(12, 20, 100, 21)];
    lblLVN.text = @"LiveVetNow";
    lblLVN.tag = kLVNTextTag;
    lblLVN.textColor = [UIColor whiteColor];
    [inAppNotificationView addSubview:lblLVN];
    
    UILabel *lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(12,36,kAppDelegate.window.frame.size.width-24,42)];
    lblMessage.textColor = [UIColor whiteColor];
    UIFont *font = lblMessage.font;
    lblMessage.font = [font fontWithSize:15];
    lblMessage.lineBreakMode = NSLineBreakByTruncatingTail ;
    lblMessage.numberOfLines = 2; // Dynamic number of lines
    [lblMessage setTextAlignment: NSTextAlignmentLeft];
    lblMessage.tag = kMessageTextTag;
    [inAppNotificationView addSubview:lblMessage];
    
    UIView *clearTapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAppDelegate.window.frame.size.width, 80)];
    clearTapView.backgroundColor = [UIColor clearColor];
    clearTapView.tag = kTapView;
    UITapGestureRecognizer *tapLeftViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationTappedAction)];
    tapLeftViewRecognizer.delegate = self;
    [clearTapView addGestureRecognizer:tapLeftViewRecognizer];
    [inAppNotificationView addSubview:clearTapView];
    [inAppNotificationView bringSubviewToFront:clearTapView];
    [self setFrameNotificationHidden];
    
    [inAppNotificationView sizeToFit];
    [kAppDelegate.window addSubview:inAppNotificationView];
    //bring subview to front
    [kAppDelegate.window bringSubviewToFront:inAppNotificationView];
    //isAlertAnimating=false;
}


-(void)notificationTappedAction {
    NSString *pushType = [self.pushPayload objectForKey:@"type"];
    if (![pushType isEqualToString:@"callStarted"]) {
        if(timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        self.isCall = NO;
        [self hideNotificationView];
        [model_manager.notificationManager notificationManagerRedirectionForNotification:self.pushPayload];
    }
}

-(void)addCallViewNotification {
    //    UIView *clearTapView = [inAppNotificationView viewWithTag:kTapView];
    //    CGRect frameTap = clearTapView.frame;
    //    frameTap.size.width = kAppDelegate.window.frame.size.width-30;
    //    clearTapView.frame = frameTap;
    inAppNotificationView.frame = CGRectMake(0,0,kAppDelegate.window.frame.size.width,110);
    //    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btnClose.frame = CGRectMake(kAppDelegate.window.frame.size.width-20,20,17,17);
    //    btnClose.tag = 5;
    //
    //    [btnClose setBackgroundImage:[[UIImage imageNamed:@"crossButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //    btnClose.tintColor = [UIColor whiteColor];
    //    [btnClose addTarget:self action:@selector(btnCloseActionIphone) forControlEvents:UIControlEventTouchUpInside];
    //    [inAppNotificationView addSubview:btnClose];
    //
    //    UIView *grayLine = [[UIView alloc]initWithFrame:CGRectMake(0, 80, kAppDelegate.window.frame.size.width, 2)];
    //    grayLine.backgroundColor = [UIColor darkGrayColor];
    //    grayLine.tag = 2;
    //    [inAppNotificationView addSubview:grayLine];
    UIButton *btnReject = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReject.frame = CGRectMake(0,inAppNotificationView.frame.size.height-30,kAppDelegate.window.frame.size.width/2,30);
    btnReject.tag = kBtnRejectCallTag;
    [btnReject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReject setTitle:@"REJECT" forState:UIControlStateNormal];
    [btnReject setBackgroundColor:[UIColor redColor]];
    //btnAccept.titleLabel.font = kRobotoBold(16);
    btnReject.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnReject addTarget:self action:@selector(btnRejectCall) forControlEvents:UIControlEventTouchUpInside];
    [inAppNotificationView addSubview:btnReject];
    
    UIButton *btnAccept = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAccept.frame = CGRectMake(kAppDelegate.window.frame.size.width/2,inAppNotificationView.frame.size.height-30,kAppDelegate.window.frame.size.width/2,30);
    btnAccept.tag = kBtnAcceptCallTag;
    [btnAccept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAccept setTitle:@"ACCEPT" forState:UIControlStateNormal];
    [btnAccept setBackgroundColor:[UIColor greenColor]];
    //btnAccept.titleLabel.font = kRobotoBold(16);
    btnAccept.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnAccept addTarget:self action:@selector(btnAcceptCall) forControlEvents:UIControlEventTouchUpInside];
    [inAppNotificationView addSubview:btnAccept];
    
}

-(void)removeCallViewNotification {
    UIButton *btnReject = [inAppNotificationView viewWithTag:kBtnRejectCallTag];
    [btnReject removeFromSuperview];
    UIButton *btnAccept = [inAppNotificationView viewWithTag:kBtnAcceptCallTag];
    [btnAccept removeFromSuperview];
}

-(void) btnRejectCall {
    if(timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [self hideNotificationView];
    NSString *aptID = @"";
    NSString *channel = @"";
    NSString *type = @"";
    if ([self.pushPayload objectForKey:@"appointmentID"]) {
        aptID = [self.pushPayload objectForKey:@"appointmentID"];
    }
    if ([self.pushPayload objectForKey:@"calltype"]) {
        type = [self.pushPayload objectForKey:@"calltype"];
    }
    if ([self.pushPayload objectForKey:@"senderID"]) {
        channel = [self.pushPayload objectForKey:@"senderID"];
    }
    [model_manager.notificationManager notifiyClientCallDeclined:channel callType:type appointmentID:aptID];
}

-(void) btnAcceptCall {
    if(timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [self hideNotificationView];
    [model_manager.notificationManager notificationManagerRedirectionForNotification:self.pushPayload];
}

#pragma mark - InApp Notification show/hide
-(void)showNotificationView:(NSString *)message {
    if ([[self.pushPayload objectForKey:@"type"] isEqualToString:@"callStarted"]) {
        self.isCall = YES;
    }
    
    if ([[self.pushPayload objectForKey:@"type"] isEqualToString:@"appointmentRequest"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appointmentRequest" object:nil];

    }
    if (!self.isCall) {
        time = 0;
        [timer invalidate];
        timer = nil;
    }
    [kAppDelegate.window bringSubviewToFront:inAppNotificationView];
    //        if (![self isNotificationViewWithInAppVisibleIphone]) {
    //            if ([[pushPayload objectForKey:@"type"] isEqualToString:@"callStarted"])
    //                isCall = YES;
    //
    UILabel *lblMessage = [inAppNotificationView viewWithTag:kMessageTextTag];
    lblMessage.text = message;
    [kAppDelegate.window bringSubviewToFront:inAppNotificationView];
    [UIView animateWithDuration:0.3 animations:^{
        [self removeCallViewNotification];
        [self setFrameNotificationVisible];
        if (self.isCall) {
            [self addCallViewNotification];
        }
    } completion:^(BOOL finished) {
        [self checkTimer];
    }];
}

-(void)checkTimer {
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTimer) userInfo:nil repeats:YES];
    time++;
    if ([self.pushPayload objectForKey:@"type"]) {
        if (self.isCall) {
            if (time>=30) {
                [timer invalidate];
                timer = nil;
                [self hideNotificationView];
            }
        }
        else if (time>=5) {
            [timer invalidate];
            timer = nil;
            [self hideNotificationView];
        }
    }
    else if (time>=5) {
        [timer invalidate];
        timer = nil;
        [self hideNotificationView];
    }
}

-(void)swipeInApp {
    [self hideNotificationView];
    UIView *grayLine = [inAppNotificationView viewWithTag:2];
    [grayLine removeFromSuperview];
    UIButton *btnSend = [inAppNotificationView viewWithTag:4];
    [btnSend removeFromSuperview];
    UIButton *btnClose = [inAppNotificationView viewWithTag:5];
    [btnClose removeFromSuperview];
}

-(void)setFrameNotificationVisible {
    inAppNotificationView.frame=CGRectMake(0,0,kAppDelegate.window.frame.size.width,80);
}

-(void)hideNotificationView {
    // [viewToSwipe removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrameNotificationHidden];
        
    } completion:^(BOOL finished) {
        //[inAppNotificationSound stop];
    }];
}

-(void)setFrameNotificationHidden {
    [self removeCallViewNotification];
    UILabel * lblLVN = [inAppNotificationView viewWithTag:kLVNTextTag];
    lblLVN.frame = CGRectMake(12, 18, 100, 21);
    inAppNotificationView.frame=CGRectMake(0,-80,kAppDelegate.window.frame.size.width,80);
}

#pragma mark - Push Notification

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    NSLog(@"deviceToken: %@", deviceToken);
    model_manager.chatVendor.devicePushToken = deviceToken;
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"DeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register with error: %@", error);
}

//Notification Delegate used after iOS 10 release
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"]) {
        [self logOut];
        return;
    }
    if (kAppDelegate.isFromPushNotification) {
        return;
    }
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        NSString *pushType = [response.notification.request.content.userInfo objectForKey:@"type"];
        if([pushType isEqualToString:@"callStarted"]) {
            [kAppDelegate.inAppNotificationSound play];
            [self handleInAppNotification:response.notification.request.content.userInfo];
        }
       else if([pushType isEqualToString:@"appointmentRequest"]) {
           
           [[NSNotificationCenter defaultCenter] postNotificationName:@"appointmentRequest" object:nil];
          
        }
        else {
            if([pushType isEqualToString:@"appointmentRequest"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"appointmentRequest" object:nil];
                
            }
            [model_manager.notificationManager notificationManagerRedirectionForNotification:response.notification.request.content.userInfo];
        }
    }
}

#pragma mark - TopMost View Controller
- (UIViewController*)topMostViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    
    // Handling UINavigationController
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    }
    // Handling Modal views
    else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    // Handling UIViewController's added as subviews to some other views.
    else {
        for (UIView *view in [rootViewController.view subviews]) {
            id subViewController = [view nextResponder];    // Key property which most of us are unaware of / rarely use.
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]]) {
                return [self topViewControllerWithRootViewController:subViewController];
            }
        }
        return rootViewController;
    }
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"LiveVetNow"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
