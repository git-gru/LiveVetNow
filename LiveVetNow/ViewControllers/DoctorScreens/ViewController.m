//
//  ViewController.m
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "ViewController.h"
@import OpenTok;
#import "Constants.h"
#import "KLCPopup.h"
#import "UIView+Customization.h"
//#import "NetworkOperation.h"
//#import "NetworkRequest.h"
//#import "Constants.h"
//#import "MBProgressHUD.h"
//#import "UIImageView+WebCache.h"
#import "HomeVC.h"
#define kTempTokenPrefix @"a1b2c3"
#define kTempTokenPostfix @"c4d5e6"

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate,UITextViewDelegate>


@end

@implementation ViewController
{
    KLCPopup* popup;

    IBOutlet UITextView *reviewTextView;
    IBOutlet UIView *viewPopup;
    IBOutlet UITextView *txtViewNotes;
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    NSOperationQueue *serialQueue;
    NSString *meetingId;
    NSMutableString *tempToken;
    NSString *userName;
    NSString *userToken;
    NSTimer *callTimer;
    NSInteger callTime;
    NSString *type;
    KLCPopup *reviewPopUp;
    IBOutlet UIButton *endCallButton;
    IBOutlet UIView *viewReviewPopUp;
    
    UIImageView *img;
    UILabel *leftCall;
}
static double widgetHeight = 240;
static double widgetWidth = 320;


// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45871042";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX40NTg3MTA0Mn5-MTQ5NjEzOTAxNjQwMX51cFJSNTg0T1AvaFZlN3hwRjMwS0ZHZkN-UH4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTg3MTA0MiZzaWc9MDZmNzQyM2Q4ODZmZTM4ZjM3OWEyMjY1N2YzM2RkYjU4NWRlMzZmNzpzZXNzaW9uX2lkPTJfTVg0ME5UZzNNVEEwTW41LU1UUTVOakV6T1RBeE5qUXdNWDUxY0ZKU05UZzBUMUF2YUZabE4zaHdSak13UzBaSFprTi1VSDQmY3JlYXRlX3RpbWU9MTQ5NjEzOTAxNiZyb2xlPXB1Ymxpc2hlciZub25jZT0xNDk2MTM5MDE2LjUwMTg2OTQ1ODQxNw==";



// Change to NO to subscribe to streams other than your own.
// bool subscribeToSelf = YES;

#pragma mark - View lifecycle
-(void)viewDidDisappear:(BOOL)animated
{
    [popup dismiss:true];
    [reviewPopUp dismiss:true];
    [self cleanupPublisher];
    [self cleanupSubscriber];
    popup = nil;
    reviewPopUp = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     indicatorView = [[MBProgressHUD alloc] initWithView:self.view];
     indicatorView.center = self.view.center;
     indicatorView.label.text = @"Loading";
     [self.view addSubview:indicatorView];
     [indicatorView showAnimated:YES];
     */
    
    viewPopup = [UIView addShadowToView:viewPopup];
    viewPopup.hidden = true;
    popup= [KLCPopup popupWithContentView:viewPopup showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    viewPopup.layer.cornerRadius = 5;
    viewPopup.clipsToBounds = true;
    
    viewReviewPopUp = [UIView addShadowToView:viewReviewPopUp];
    viewReviewPopUp.hidden = true;
    reviewPopUp = [KLCPopup popupWithContentView:viewReviewPopUp showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    viewReviewPopUp.layer.cornerRadius = 5;
    viewReviewPopUp.clipsToBounds = true;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    serialQueue  = [[NSOperationQueue alloc] init];
    serialQueue.maxConcurrentOperationCount = 1;
    
    endCallButton.hidden = true;
    
    
    //    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    //    {
    //
    //        img=[[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-200, 400, 400)];
    //    }
    //    else{
    img=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 200)];
    // }
    
    img.layer.cornerRadius=100/2;
    
    img.clipsToBounds=YES;
    
    leftCall=[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-10, self.view.frame.size.width, 20)];
    leftCall.font=[UIFont systemFontOfSize:15];
    leftCall.textAlignment=NSTextAlignmentCenter;
    
    //    [view addSubview:button];
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kMeetingIdReceivedNotification object:nil];
    
    callTime=0;
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kMeetingIdReceivedNotification object:nil];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    /*
     _session = [[OTSession alloc] initWithApiKey:kApiKey
     sessionId:kSessionId
     delegate:self];
     [self doConnect];
     */
    //[self getUserInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"callStarted" object:nil];

   [self establishOpentokSession];
    
}


-(void)notificationReceived:(NSNotification *)notification {
    
    
    [model_manager.tokbox_Manager fetchTokBoxSessionWithAppointmentID:[NSString stringWithFormat:@"%@",notification.object] withCompletionBlock:^(BOOL success, NSDictionary * dict)
     {
         if (success)
         {
             
             _dictSessionData = [NSDictionary dictionaryWithDictionary:dict];
             // got the tokbox details continue with tokbox now
             // [self establishOpentokSession];
             UIStoryboard *calling = [UIStoryboard storyboardWithName:@"Calling" bundle:nil];
             
            // ViewController *obj = [calling instantiateInitialViewController];
             self.appointmentID = notification.object;
             
             self.dictSessionData = _dictSessionData;
          //   obj.hidesBottomBarWhenPushed = true;
             [self establishOpentokSession];
            // [self.navigationController pushViewController:obj animated:false];
         }
         
     }];
    
    
}

#pragma mark - Custom Methods
/*
 -(void)getUserInfo
 {
 // NSMutableDictionary *dictParameters = [[NSMutableDictionary alloc] init];
 //1) Create a network request operation to get the user token and user id
 NSLog(@"meeting%@",meetingId);
 NSLog(@"temptoken%@",tempToken);
 
 // NSDictionary *bodyDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"meeting_id",@"",@"temptoken", nil];
 NSDictionary *bodyDictionary = [NSDictionary dictionaryWithObjects:@[meetingId,tempToken] forKeys:@[@"meeting_id",@"temptoken"]];
 NSDictionary *dictHeader = @{@"content-type":@"application/json"};
 NetworkRequest *requestUserDetail = [[NetworkRequest alloc] initWithPath:kGetUserInfoPath HTTPMethod:@"POST" headers:dictHeader body:bodyDictionary];
 NSOperation *getUserDetailSession = [[NetworkOperation alloc] initWithRequest:requestUserDetail completionHandler:^(NSDictionary *dict, NSError *error)
 {
 if ([[dict valueForKey:@"success"] boolValue])
 {
 if ([dict valueForKey:@"user_name"] && [[dict valueForKey:@"user_name"] length] > 0)
 {
 userName = [dict valueForKey:@"user_name"];
 }
 
 if ([dict valueForKey:@"user_token"] && [[dict valueForKey:@"user_token"] length] > 0)
 {
 userToken = [dict valueForKey:@"user_token"];
 }
 
 [self getOpentokSessionID];
 }
 }];
 [serialQueue addOperation:getUserDetailSession];
 // We want the queue to perform operations serially
 }
 
 -(void)getOpentokSessionID
 {
 //2) Create a network request operation to get the Opentok Session Id by passing the meeting id
 NSDictionary *headers = [NSDictionary dictionaryWithObjects:@[userToken,userName] forKeys:@[@"usertoken",@"username"]];
 NSString *path = [NSString stringWithFormat:@"%@/%@",kGetOpentokSessionPath,meetingId];
 NetworkRequest *getSessionRequest = [[NetworkRequest alloc] initWithPath:path HTTPMethod:@"GET" headers:headers body:nil];
 NSOperation *getSessionOperation = [[NetworkOperation alloc] initWithRequest:getSessionRequest completionHandler:^(NSDictionary *dict, NSError *error) {
 NSLog(@"dict is %@",dict);
 // Store the
 if ([[dict valueForKey:@"success"] boolValue])
 {
 dictSessionData =  [[NSDictionary alloc] initWithDictionary:dict];
 [self establishOpentokSession];
 }
 
 }];
 
 [serialQueue addOperation:getSessionOperation];
 }
 */
-(void)establishOpentokSession
{
    _session = [[OTSession alloc] initWithApiKey:[self.dictSessionData objectForKey:@"api_key"]
                                       sessionId:[self.dictSessionData objectForKey:@"session_id"]
                                        delegate:self];
    [self doConnect];
}
/*
 -(void)changeCallStatusAndNotifyOtherUser
 {
 // serialQueue.maxConcurrentOperationCount = 3;
 NSDictionary *headers = [NSDictionary dictionaryWithObjects:@[userToken,userName,@"application/json"] forKeys:@[@"usertoken",@"username",@"Content-Type"]];
 NSString *path = [NSString stringWithFormat:@"%@/%@",kChangeMeetingStatusPath,meetingId];
 NetworkRequest *getSessionRequest = [[NetworkRequest alloc] initWithPath:path HTTPMethod:@"PUT" headers:headers body:nil];
 NSOperation *changeCallStatusOperation = [[NetworkOperation alloc] initWithRequest:getSessionRequest completionHandler:^(NSDictionary *dict, NSError *error) {
 NSLog(@"dict is %@",dict);
 // Store the
 if ([[dict valueForKey:@"success"] boolValue])
 {
 }
 
 }];
 
 NSMutableDictionary *dictBodyParams = [[NSMutableDictionary alloc] init];
 [dictBodyParams setValue:[dictSessionData valueForKey:@"receiver_email"] forKey:@"receiver"];
 [dictBodyParams setValue:@"callrequest" forKey:@"type"];
 NSMutableString *strText = [[NSMutableString alloc] init] ;
 
 if ([[dictSessionData valueForKey:@"appointment_type"] isEqualToString:@"video call"])
 {
 [strText appendString:@"Video"];
 }
 else
 {
 [strText appendString:@"Audio"];
 }
 
 if ([[dictSessionData valueForKey:@"sender_email"] isEqualToString:[dictSessionData valueForKey:@"doctor_email"]])
 {
 [strText appendFormat:@"%@%@",@"####",[dictSessionData valueForKey:@"doctor_name"]];
 }
 else
 {
 [strText appendFormat:@"%@%@",@"####",[dictSessionData valueForKey:@"msl_name"]];
 }
 
 [dictBodyParams setValue:strText forKey:@"text"];
 [dictBodyParams setValue:meetingId forKey:@"data_id"];
 NSMutableDictionary *sender = [[NSMutableDictionary alloc] init];
 
 [sender setValue:[dictSessionData valueForKey:@"sender_email"] forKey:@"user_id"] ;
 [dictBodyParams setValue:sender forKey:@"sender"];
 
 
 path = [NSString stringWithFormat:@"%@",kSendNotificationPath];
 NetworkRequest *sendNotificationRequest = [[NetworkRequest alloc] initWithPath:path HTTPMethod:@"POST" headers:headers body:dictBodyParams];
 NSOperation *notifyOperation = [[NetworkOperation alloc] initWithRequest:sendNotificationRequest completionHandler:^(NSDictionary *dict, NSError *error) {
 NSLog(@"dict is %@",dict);
 // Store the
 if ([[dict valueForKey:@"success"] boolValue])
 {
 }
 
 }];
 
 [serialQueue addOperation:changeCallStatusOperation];
 [serialQueue addOperation:notifyOperation ];
 }
 */
/*
 -(void)saveCallDuration
 {
 //) Create a network request operation to save the call duration to server
 NSDictionary *headers = [NSDictionary dictionaryWithObjects:@[userToken,userName] forKeys:@[@"usertoken",@"username"]];
 NSString *path = [NSString stringWithFormat:@"%@/%@/%li",kSaveCallDurationPath,meetingId,(long)callTime];
 NetworkRequest *saveSessionTimeRequest = [[NetworkRequest alloc] initWithPath:path HTTPMethod:@"PUT" headers:headers body:nil];
 NSOperation *saveSessionTimeOperation = [[NetworkOperation alloc] initWithRequest:saveSessionTimeRequest completionHandler:^(NSDictionary *dict, NSError *error) {
 NSLog(@"dict is %@",dict);
 // Store the
 if ([[dict valueForKey:@"success"] boolValue])
 {
 callTime = 0 ;
 [callTimer invalidate];
 callTimer=nil;
 NSLog(@"dicy is %@",dict);
 }
 
 }];
 
 [serialQueue addOperation:saveSessionTimeOperation];
 }
 */
-(void)recordCallTime
{
    callTime++;
    NSLog(@"call Time");
}
#pragma mark - Rotation Methods
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - OpenTok methods
/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    [_session connectWithToken:[self.dictSessionData objectForKey:@"token"] error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    /*
    if ([[dictSessionData objectForKey:@"appointment_type"]isEqualToString:@"audio call"]) {
        _publisher = [[OTPublisher alloc] initWithDelegate:self
                                                      name:[[UIDevice currentDevice] name]
                                                audioTrack:YES
                                                videoTrack:NO];
    }
     */
    
        
        _publisher = [[OTPublisher alloc] initWithDelegate:self
                                                      name:[[UIDevice currentDevice] name]
                                                audioTrack:YES
                                                videoTrack:YES];
        
    
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
    //    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    //    {
    //  [_publisher.view setFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width/2-150, 200)];
    //    }
    //    else{
    [_publisher.view setFrame:CGRectMake(0, self.view.frame.size.height-100,  100, 100)];
    //  }
    
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
- (void)cleanupPublisher {
    OTError *error = nil;
    
    
    [_session unpublish:_publisher error:&error];
    
    [_publisher.view removeFromSuperview];
    
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */

/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber
{
    
    [_subscriber.view removeFromSuperview];
    
    _subscriber = nil;
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    // AFTER CONNECTION HAS BEEN SET UP SUCCESSFULLY , SEND NOTIFICATION TO OTHER USER AS WELL CHANGE THE CALL STATUS
    if ([type isEqualToString:@"receiver"]) {
        //nothing
    }
    else{
        // [self changeCallStatusAndNotifyOtherUser];
    }
    
    if (!kAppDelegate.isVet) {
        //channel ie Vet's ID and calltype
        [model_manager.notificationManager notifiyVetCallStarted:[NSString stringWithFormat:@"%@",self.currentVet.vetId] callType:@"video" appointmentID:self.appointmentID];
    }
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
    
    
    
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
   // [self endCall];

    //  [self saveCallDuration];
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
   // callTime=0;
    //callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordCallTime) userInfo:nil repeats:YES];
    
    [self createSubscriber:stream];
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    [self endCall];
    
    
    // [self saveCallDuration];
    
    /*
    
    if ([userName isEqualToString:[dictSessionData objectForKey:@"msl_email"]]) {
        //
        leftCall.text=[NSString stringWithFormat:@"%@ has left the call.",[dictSessionData valueForKey:@"doctor_name"]];
    }
    else{
        leftCall.text=[NSString stringWithFormat:@"%@ has left the call.",[dictSessionData valueForKey:@"msl_name"]];
    }
    
    
    
    [self.view addSubview:leftCall];
    
    [img removeFromSuperview];
    
    [endCallbutton removeFromSuperview];
     */
    
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    
   // [self endCall];

    
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
   // [self endCall];

}

# pragma mark - OTSubscriber delegate callbacks


- (void)createSubscriber:(OTStream *)stream
{
    
    if ([[UIApplication sharedApplication] applicationState] ==
        UIApplicationStateBackground ||
        [[UIApplication sharedApplication] applicationState] ==
        UIApplicationStateInactive)
    {
    } else
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc]
                                    initWithStream:stream delegate:self];
        
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
        
    }
}

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
  //  if (![[dictSessionData objectForKey:@"appointment_type"]isEqualToString:@"audio call"]) {
        // You may want to adjust the user interface
        _subscriber=(OTSubscriber*)subscriber;
        [_subscriber.view setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                              self.view.frame.size.height)];
        
        
        [self.view addSubview:_subscriber.view];
        [self.view bringSubviewToFront:_publisher.view];
        //   [indicatorView removeFromSuperview];
        self.view.alpha=1.0f;
        
    //}
   // else{
        
        // [indicatorView removeFromSuperview];
      //  self.view.alpha=1.0f;
        
      //  [self.view addSubview:img];
        /*
         if ([userName isEqualToString:[dictSessionData objectForKey:@"msl_email"]]) {
         
         [img sd_setImageWithURL:[NSURL URLWithString:[dictSessionData objectForKey:@"doctor_pic"]] placeholderImage:[UIImage imageNamed:@"defaultProfile.png"] options:SDWebImageRetryFailed | SDWebImageRefreshCached];
         }
         else{
         [img sd_setImageWithURL:[NSURL URLWithString:[dictSessionData objectForKey:@"msl_pic"]] placeholderImage:[UIImage imageNamed:@"defaultProfile.png"] options:SDWebImageRetryFailed | SDWebImageRefreshCached];
         }
         
         }
         */
   // }
    endCallButton.hidden = false;
    [self.view bringSubviewToFront:endCallButton];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    
    //why to subscribe to our own stream for just the sake of adding a subscriber view it will be added when session stream is created
    
    //    [self createSubscriber:stream];
    
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
  //  [self endCall];

    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    [self cleanupSubscriber];
    
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
   // [self endCall];
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return textView.text.length + (text.length - range.length) <= 150;
    
    
}
/*
#pragma mark - Observers
-(void)notificationReceived:(NSNotification *)notification
{
    
    meetingId=[notification.object objectForKey:@"meetingid"];
    type=[notification.object objectForKey:@"type"];
    
    NSString *encodedToken = [notification.object objectForKey:@"temptoken"];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedToken options:0];
    encodedToken  = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", encodedToken); //
    
    encodedToken = [encodedToken stringByReplacingOccurrencesOfString:kTempTokenPrefix withString:@""];
    
    encodedToken = [encodedToken stringByReplacingOccurrencesOfString:kTempTokenPostfix withString:@""];
    
    
    NSMutableString *reversedString = [NSMutableString string];
    NSInteger charIndex = [encodedToken length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedString appendString:[encodedToken substringWithRange:subStrRange]];
    }
    tempToken=reversedString;
    //[self getUserInfo];
}
 */
- (IBAction)endCallButtonAction:(id)sender {
    [self cleanupPublisher];
    [self cleanupSubscriber];
}


-(void)endCall
{
    [self cleanupPublisher];
    [self cleanupSubscriber];
    [img removeFromSuperview];
    [endCallButton setHidden:true];
    if (kAppDelegate.isVet)

    {
        viewPopup.hidden = false;
        [popup show];
       
        
    }
    else{
        
       
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Would you like to call again or want to end the call by submitting a review for the doctor?" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self establishOpentokSession];

            // Cancel button tappped.
            [alert dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Submit Review" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            viewReviewPopUp.hidden = false;
            [reviewPopUp show];
            
            // Cancel button tappped.
            [alert dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        
        [self presentViewController:alert animated:true completion:nil];
        
        
    }
    
    // [self saveCallDuration];
}

- (IBAction)btnSubmitAction:(id)sender {
   
    if (reviewTextView.text.length == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please fill a review for the doctor." preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [alert dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:reviewTextView.text,@"review", [NSString stringWithFormat:@"%@",self.currentVet.vetId] ,@"doctor_id",self.appointmentID,@"apt_id",nil];
    // add notes
    [model_manager.appointment_Manager addReview:dict withCompletionBlock:^(BOOL success, NSString *message)
     {
         [reviewPopUp dismiss:true];
         [self.navigationController popViewControllerAnimated:true];
         if (success)
         {
             [reviewPopUp dismiss:true];
            
             HomeVC *obj = [self.navigationController.viewControllers objectAtIndex:0];
             
             [self.navigationController popToViewController:obj animated:true];

             [self.navigationController popViewControllerAnimated:true];
             
         }
         else{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Live Vet Now" message:message preferredStyle:UIAlertControllerStyleAlert];
             
             [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                 
                 // Cancel button tappped.
                 [alert dismissViewControllerAnimated:true completion:nil];
                 
             }]];
             
             [self presentViewController:alert animated:true completion:nil];
         }
         
     }];
    

    
}



- (IBAction)btnSaveAction:(id)sender {
    if (txtViewNotes.text.length == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please fill some notes for the pet" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [alert dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:txtViewNotes.text,@"note", self.appointmentID,@"apt_id",nil];
    // add notes
    [model_manager.appointment_Manager addNote:dict withCompletionBlock:^(BOOL success, NSString *message)
     {
         [popup dismiss:true];
         [self.navigationController popViewControllerAnimated:true];
         if (success)
         {
             [popup dismiss:true];
             [self.navigationController popViewControllerAnimated:true];
             
         }
         else{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Live Vet Now" message:message preferredStyle:UIAlertControllerStyleAlert];
             
             [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                 
                 // Cancel button tappped.
                 [alert dismissViewControllerAnimated:true completion:nil];
                 
             }]];
             
             [self presentViewController:alert animated:true completion:nil];
         }
         
     }];
    
    
    
}


@end
