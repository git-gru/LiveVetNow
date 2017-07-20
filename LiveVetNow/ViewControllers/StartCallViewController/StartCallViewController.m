//
//  StartCallViewController.m
//  LiveVetNow
//
//  Created by Apple on 21/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//


#import "StartCallViewController.h"
#import "Constants.h"
#import "ViewController.h"
#import "HomeVC.h"
@import OpenTok;

@interface StartCallViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

{
    IBOutlet UILabel *goodToGoLabel;
    
    IBOutlet NSLayoutConstraint *btnCancelWidthConstraint;
    IBOutlet UIButton *btnStartCall;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *lblLocation;
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    NSDictionary *dictSessionData;
    UIImageView *img;
    UILabel *leftCall;
    UIButton *endCallbutton;
    IBOutlet UILabel *lblName;

}

@end

@implementation StartCallViewController

// Replace with your OpenTok API key
static NSString* const kApiKey = @"45871042";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX40NTg3MTA0Mn5-MTQ5NjEzOTAxNjQwMX51cFJSNTg0T1AvaFZlN3hwRjMwS0ZHZkN-UH4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTg3MTA0MiZzaWc9MDZmNzQyM2Q4ODZmZTM4ZjM3OWEyMjY1N2YzM2RkYjU4NWRlMzZmNzpzZXNzaW9uX2lkPTJfTVg0ME5UZzNNVEEwTW41LU1UUTVOakV6T1RBeE5qUXdNWDUxY0ZKU05UZzBUMUF2YUZabE4zaHdSak13UzBaSFprTi1VSDQmY3JlYXRlX3RpbWU9MTQ5NjEzOTAxNiZyb2xlPXB1Ymxpc2hlciZub25jZT0xNDk2MTM5MDE2LjUwMTg2OTQ1ODQxNw==";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    endCallbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [endCallbutton addTarget:self
                      action:@selector(endCall)
            forControlEvents:UIControlEventTouchUpInside];
    [endCallbutton setImage:[UIImage imageNamed:@"EndCall"]  forState:UIControlStateNormal];
    endCallbutton.frame = CGRectMake(self.view.frame.size.width/2-20, self.view.frame.size.height-85, 40, 40);
    
    img=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 200)];
    
    
    img.layer.cornerRadius=100/2;
    
    img.clipsToBounds=YES;
    
    leftCall=[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-10, self.view.frame.size.width, 20)];
    leftCall.font=[UIFont systemFontOfSize:15];
    leftCall.textAlignment=NSTextAlignmentCenter;
    lblName.text = self.currentVet.name;
    [lblLocation setTitle:self.currentVet.state forState:UIControlStateNormal];
    
    
}
- (IBAction)startCallAction:(id)sender {
   
    
    goodToGoLabel.hidden = true;
    btnCancelWidthConstraint.constant = 250;
    btnStartCall.hidden = true;
    [btnCancel setTitle:@"End Call" forState:UIControlStateNormal];
    [btnCancel setBackgroundColor:[UIColor redColor]];
    
    [model_manager.tokbox_Manager fetchTokBoxSessionWithAppointmentID:self.appointmentID withCompletionBlock:^(BOOL success, NSDictionary * dict)
     {
         if (success)
         {
             
             dictSessionData = [NSDictionary dictionaryWithDictionary:dict];
             // got the tokbox details continue with tokbox now
            // [self establishOpentokSession];
             
             UIStoryboard *calling = [UIStoryboard storyboardWithName:@"Calling" bundle:nil];
             
             ViewController *obj = [calling instantiateInitialViewController];

             obj.dictSessionData = dictSessionData;
             obj.currentVet = self.currentVet;
             obj.appointmentID = self.appointmentID;
             [self.navigationController pushViewController:obj animated:true];

         }
     
     }];
    

}
- (IBAction)cancelBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];

}

-(void)establishOpentokSession
{
    _session = [[OTSession alloc] initWithApiKey:[NSString stringWithFormat:@"%@",[dictSessionData objectForKey:@"api_key"]]
                                       sessionId:[NSString stringWithFormat:@"%@",[dictSessionData objectForKey:@"session_id"]]
                                        delegate:self];
    [self doConnect];
}

#pragma mark - OpenTok methods
/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    [_session connectWithToken:[NSString stringWithFormat:@"%@",[dictSessionData objectForKey:@"token"]]error:&error];
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
    OTPublisherSettings *_publisherSettings = [[OTPublisherSettings alloc] init];

        _publisherSettings.videoTrack = YES;
    _publisherSettings.audioTrack = YES;
        _publisher = [[OTPublisher alloc]initWithDelegate:self settings:_publisherSettings];
        
   
        _publisher = [[OTPublisher alloc]initWithDelegate:self settings:_publisherSettings];

        
    
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
   // if ([type isEqualToString:@"receiver"]) {
        //nothing
   // }
    //else{
        // [self changeCallStatusAndNotifyOtherUser];
    //}
    
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
    
    [self cleanupPublisher];
    
    [self cleanupSubscriber];
    
    // [self saveCallDuration];
    
    /*
    if ([userName isEqualToString:[dictSessionData objectForKey:@"msl_email"]]) {
        //
        leftCall.text=[NSString stringWithFormat:@"%@ has left the call.",[dictSessionData valueForKey:@"doctor_name"]];
    }
    else{
        leftCall.text=[NSString stringWithFormat:@"%@ has left the call.",[dictSessionData valueForKey:@"msl_name"]];
    }
     */
    
    
    
    
    [self.view addSubview:leftCall];
    
    [img removeFromSuperview];
    
    [endCallbutton removeFromSuperview];
    
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
    
    [self cleanupSubscriber];
    [self cleanupPublisher];
    
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
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
    if (![[dictSessionData objectForKey:@"appointment_type"]isEqualToString:@"audio call"]) {
        // You may want to adjust the user interface
        _subscriber=(OTSubscriber*)subscriber;
        [_subscriber.view setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                              self.view.frame.size.height)];
        
        
        [self.view addSubview:_subscriber.view];
        [self.view bringSubviewToFront:_publisher.view];
        //   [indicatorView removeFromSuperview];
        self.view.alpha=1.0f;
        
    }
    else{
        
        // [indicatorView removeFromSuperview];
        self.view.alpha=1.0f;
        
        [self.view addSubview:img];
        /*
         if ([userName isEqualToString:[dictSessionData objectForKey:@"msl_email"]]) {
         
         [img sd_setImageWithURL:[NSURL URLWithString:[dictSessionData objectForKey:@"doctor_pic"]] placeholderImage:[UIImage imageNamed:@"defaultProfile.png"] options:SDWebImageRetryFailed | SDWebImageRefreshCached];
         }
         else{
         [img sd_setImageWithURL:[NSURL URLWithString:[dictSessionData objectForKey:@"msl_pic"]] placeholderImage:[UIImage imageNamed:@"defaultProfile.png"] options:SDWebImageRetryFailed | SDWebImageRefreshCached];
         }
         
         }
         */
    }
    
    [self.view addSubview:endCallbutton];
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
    
       // [self createSubscriber:stream];
    
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
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
    [self cleanupPublisher];
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
#pragma mark - Observers
/*
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
-(void)endCall
{
    
   // _publisher.publishAudio = true;
   // _publisher.publishVideo = false;
    
    [self cleanupPublisher];
    [self cleanupSubscriber];
    [img removeFromSuperview];
   
    HomeVC *obj = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:obj animated:true];
    
    // [self saveCallDuration];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
