//
//  DoctorHomeViewController.m
//  LiveVetNow
//
//  Created by Apple on 28/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "DoctorHomeViewController.h"
#import "Constants.h"
#import "MyMeetingTableViewCell.h"
#import "Appointment.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
@import OpenTok;
#import "MBProgressHUD.h"
#import "ViewController.h"
#import "MeetingDetailViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "MFSideMenu.h"
#import "EmailDetailViewController.h"

@interface DoctorHomeViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
{
    __weak IBOutlet UITableView *tableViewVetMeetings;
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    NSOperationQueue *serialQueue;
    NSString *meetingId;
    NSMutableString *tempToken;
    NSString *userName;
    NSString *userToken;
    NSDictionary *dictSessionData;
    NSTimer *callTimer;
    NSInteger callTime;
    NSString *type;
    UIButton *endCallbutton;
    UIButton *switchFrontBackCamera;
    
    IBOutlet UISegmentedControl *segmentedControl;
    UIImageView *img;
    UILabel *leftCall;
}

@end


@implementation DoctorHomeViewController
-(void)viewWillAppear:(BOOL)animated
{
    
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableViewVetMeetings.hidden = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"callStarted" object:nil];
    [self customiseSegmentedControl];
    endCallbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [endCallbutton addTarget:self action:@selector(endCall)
            forControlEvents:UIControlEventTouchUpInside];
    [endCallbutton setImage:[UIImage imageNamed:@"EndCall"]  forState:UIControlStateNormal];
    endCallbutton.frame = CGRectMake(self.view.frame.size.width/2-20, self.view.frame.size.height-85, 40, 40);
   
   
     img=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2-100, 100, 100)];
    
    img.layer.cornerRadius=100/2;
    img.backgroundColor = [UIColor blueColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"appointmentRequest" object:nil];

    
    img.clipsToBounds=YES;
    
    leftCall=[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-10, self.view.frame.size.width, 20)];
    leftCall.font=[UIFont systemFontOfSize:15];
    leftCall.textAlignment=NSTextAlignmentCenter;
    ///[ self establishOpentokSession];
    [self getAppointmentsList];
    [self getTransactionsList];
}
- (IBAction)buttonOpenMenuAction:(id)sender {
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];

}

-(void)notificationReceived:(NSNotification *)notification {
  
    if ([notification.name isEqualToString:@"callStarted"])
    {
    [model_manager.tokbox_Manager fetchTokBoxSessionWithAppointmentID:[NSString stringWithFormat:@"%@",notification.object] withCompletionBlock:^(BOOL success, NSDictionary * dict)
     {
         if (success)
         {
             
             dictSessionData = [NSDictionary dictionaryWithDictionary:dict];
             // got the tokbox details continue with tokbox now
             // [self establishOpentokSession];
             UIStoryboard *calling = [UIStoryboard storyboardWithName:@"Calling" bundle:nil];
             
             ViewController *obj = [calling instantiateInitialViewController];
             obj.appointmentID = notification.object;
            
             obj.dictSessionData = dictSessionData;
             obj.hidesBottomBarWhenPushed = true;
             [self.navigationController pushViewController:obj animated:false];
         }
         
     }];
    }
    else{
        
        [self getAppointmentsList];
    }

}


-(void)getTransactionsList {
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.appointment_Manager getTransactionsList:nil withCompletionBlock:^(BOOL success, NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
}

-(void)getAppointmentsList {
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.appointment_Manager getAppointmentsList:nil withCompletionBlock:^(BOOL success, NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            if (segmentedControl.selectedSegmentIndex == 0) {
                if(model_manager.appointment_Manager.arrayUpcomingAppointments.count<=0)
                    tableViewVetMeetings.hidden = YES;
                else
                    tableViewVetMeetings.hidden = NO;
            }
            else {
                if(model_manager.appointment_Manager.arrayNewRequests.count<=0)
                    tableViewVetMeetings.hidden = YES;
                else
                    tableViewVetMeetings.hidden = NO;
            }
            [tableViewVetMeetings reloadData];
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
}


#pragma mark SegmentedControl Methods
-(void)customiseSegmentedControl
{
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    // set first segment selected
    
    for (int i=0; i<[segmentedControl.subviews count]; i++)
    {
        if ([[segmentedControl.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor=[UIColor colorWithRed:25.0/255.0 green:69.0/255.0 blue:169.0/255.0 alpha:1];
            [[segmentedControl.subviews objectAtIndex:i] setTintColor:tintcolor];
            [segmentedControl.subviews objectAtIndex:i].layer.cornerRadius = segmentedControl.frame.size.height/2;
            [segmentedControl.subviews objectAtIndex:i].layer.masksToBounds = YES;
            
        }
        else
        {
            [[segmentedControl.subviews objectAtIndex:i] setTintColor:nil];
        }
    }
    
}
- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)valueChanged:(UISegmentedControl *)sender {
    for (int i=0; i<[sender.subviews count]; i++) {
        if ([[sender.subviews objectAtIndex:i]isSelected]) {
            UIColor *tintcolor=[UIColor colorWithRed:25.0/255.0 green:69.0/255.0 blue:169.0/255.0 alpha:1];
            [[sender.subviews objectAtIndex:i] setTintColor:tintcolor];
            [sender.subviews objectAtIndex:i].layer.cornerRadius = segmentedControl.frame.size.height/2;
            [sender.subviews objectAtIndex:i].layer.masksToBounds = YES;
            
        }
        else {
            [[sender.subviews objectAtIndex:i] setTintColor:nil];
        }
    }
    if (segmentedControl.selectedSegmentIndex == 0) {
        if(model_manager.appointment_Manager.arrayUpcomingAppointments.count<=0)
            tableViewVetMeetings.hidden = YES;
        else
            tableViewVetMeetings.hidden = NO;
    }
    else {
        if(model_manager.appointment_Manager.arrayNewRequests.count<=0)
            tableViewVetMeetings.hidden = YES;
        else
            tableViewVetMeetings.hidden = NO;
    }
    [tableViewVetMeetings reloadData];
}




#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (segmentedControl.selectedSegmentIndex == 0) {
        return model_manager.appointment_Manager.arrayUpcomingAppointments.count;
    }
    else {
        return model_manager.appointment_Manager.arrayNewRequests.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyMeetingTableViewCell *customListingCell = (MyMeetingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomDoctorMyMeetingCell];
    Appointment *currentAppointment;
    if (segmentedControl.selectedSegmentIndex == 0) {
        currentAppointment = [model_manager.appointment_Manager.arrayUpcomingAppointments objectAtIndex:indexPath.row];
        customListingCell.statusButton.hidden = false;

        if ([currentAppointment.appointment_status isEqualToString:@"accepted"] || [currentAppointment.appointment_status isEqualToString:@"confirmed"])
        {
            
            customListingCell.btnReject.hidden = false;
            [customListingCell.btnReject setTitle:@"MESSAGE" forState:UIControlStateNormal];
            if ([currentAppointment.appointment_status isEqualToString:@"accepted"])
            {
                
                [customListingCell.statusButton setTitle:@"UNPAID" forState:UIControlStateNormal];
                [customListingCell.statusButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                
                [customListingCell.statusButton setImage:nil forState:UIControlStateNormal];
            }
            else{
                
                [customListingCell.statusButton setTitle:@"PAID" forState:UIControlStateNormal];
                [customListingCell.statusButton setTitleColor:[UIColor colorWithRed:35.0/255.0 green:192.0/255.0 blue:104.0/255.0 alpha:1] forState:UIControlStateNormal];

                [customListingCell.statusButton setImage:[UIImage imageNamed:@"GreenTick"] forState:UIControlStateNormal];
            }
            

        }
        else{
            
            customListingCell.btnReject.hidden = false;
            [customListingCell.btnReject setTitle:@"CANCEL" forState:UIControlStateNormal];
            [customListingCell.statusButton setTitle:@"UNPAID" forState:UIControlStateNormal];
            [customListingCell.statusButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

            [customListingCell.statusButton setImage:nil forState:UIControlStateNormal];

        }
        [customListingCell.btnAccept setTitle:@"VIEW DETAIL" forState:UIControlStateNormal];
        [customListingCell.btnAccept setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:83.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];
    }
    else {
        [customListingCell.btnAccept setTitle:@"ACCEPT" forState:UIControlStateNormal];
        [customListingCell.btnReject setTitle:@"REJECT" forState:UIControlStateNormal];
        [customListingCell.btnAccept setBackgroundColor:[UIColor colorWithRed:35.0f/255.0f green:192.0f/255.0f blue:104.0f/255.0f alpha:1.0f]];
        customListingCell.statusButton.hidden = true;
        customListingCell.btnReject.hidden = false;

        currentAppointment = [model_manager.appointment_Manager.arrayNewRequests objectAtIndex:indexPath.row];
    }

    [customListingCell.btnAccept addTarget:self action:@selector(appointmentAcceptButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [customListingCell.btnReject addTarget:self action:@selector(appointmentRejectButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    if (currentAppointment) {
        [customListingCell.imgViewVet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentAppointment.user_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                customListingCell.imgViewVet.image = image;
            else
                customListingCell.imgViewVet.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        customListingCell.lblClientName.text = currentAppointment.user_name.capitalizedString;
        customListingCell.btnClientLocation.hidden = YES;
         [customListingCell.btnDate setTitle:currentAppointment.appointmentDate forState:UIControlStateNormal];
         [customListingCell.btnTime setTitle:currentAppointment.appointmentTime forState:UIControlStateNormal];
    
        customListingCell.lblPetName.text = currentAppointment.pet_name.capitalizedString;
        [customListingCell.imgViewPet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentAppointment.pet_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                customListingCell.imgViewPet.image = image;
            else
                customListingCell.imgViewPet.image = [UIImage imageNamed:@"dummyDog"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        customListingCell.lblPetInfo.text = [NSString stringWithFormat:@"%@-%@-%@MONTHS",[currentAppointment.pet_type capitalizedString],[currentAppointment.pet_sex capitalizedString],[currentAppointment.pet_age capitalizedString]];
    }
    return customListingCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Appointment *currentAppointment;
    if (segmentedControl.selectedSegmentIndex == 0) {
        currentAppointment = [model_manager.appointment_Manager.arrayUpcomingAppointments objectAtIndex:indexPath.row];
    }
    else {
        currentAppointment = [model_manager.appointment_Manager.arrayNewRequests objectAtIndex:indexPath.row];
    }
    if (currentAppointment) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MeetingDetail" bundle:nil];
        MeetingDetailViewController *detail = [storyBoard instantiateInitialViewController];
        detail.selectedAppointment = currentAppointment;
        [self.navigationController pushViewController:detail animated:true];
    }
}

-(void)appointmentRejectButtonAction:(UIButton*)sender {
    
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewVetMeetings];
    NSIndexPath *indexPath = [tableViewVetMeetings indexPathForRowAtPoint:rootViewPoint];
    Appointment *currentAppointment;
    if (segmentedControl.selectedSegmentIndex == 0) {
        currentAppointment = [model_manager.appointment_Manager.arrayUpcomingAppointments objectAtIndex:indexPath.row];
    }
    else {
        currentAppointment = [model_manager.appointment_Manager.arrayNewRequests objectAtIndex:indexPath.row];
    }

    if ([sender.currentTitle isEqualToString:@"CANCEL"] || [sender.currentTitle isEqualToString:@"REJECT"])
    {
       if (currentAppointment) {
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setValue:currentAppointment.apt_id forKey:@"apt_id"];
        [tempDict setValue:@"cancelled" forKey:@"apt_status"];
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                if (segmentedControl.selectedSegmentIndex == 0) {
                    [model_manager.notificationManager notifiyAppointmentRequestCancelled:currentAppointment.user_id appointmentID:currentAppointment.apt_id];
                    [self getAppointmentsList];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Cancelled Successfully."] animated:YES completion:nil];
                }
                else {
                    [model_manager.notificationManager notifiyClientAppointmentRequestRejected:currentAppointment.user_id appointmentID:currentAppointment.apt_id];
                    [self getAppointmentsList];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Rejected Successfully."] animated:YES completion:nil];
                }
            }
            else{
                [kAppDelegate showAlert:message];
            }
        }];
    }
    }
    else{
        if ([currentAppointment.appointment_status isEqualToString:@"confirmed"])
        {
            
            if (kAppDelegate.isVet) {
                [self sendMessageTo:currentAppointment.user_name userId:currentAppointment.user_id];
            }
            else {
                [self sendMessageTo:currentAppointment.doctor_name userId:currentAppointment.doctor_id];
            }
            
        }
        
        
    }
}
-(void)sendMessageTo:(NSString*)name userId:(NSString*)recieverId  {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
    EmailDetailViewController *objEmailDetail = [storyboard instantiateViewControllerWithIdentifier:@"EmailDetailVC"];
    objEmailDetail.receiverId = recieverId;
    objEmailDetail.receiverName = name;
    [self.navigationController pushViewController:objEmailDetail animated:true];
}


-(void)appointmentAcceptButtonAction:(UIButton*)sender {
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewVetMeetings];
    NSIndexPath *indexPath = [tableViewVetMeetings indexPathForRowAtPoint:rootViewPoint];
    
    Appointment *currentAppointment;
    if (segmentedControl.selectedSegmentIndex == 0) {
        currentAppointment = [model_manager.appointment_Manager.arrayUpcomingAppointments objectAtIndex:indexPath.row];
        if (currentAppointment) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MeetingDetail" bundle:nil];
            MeetingDetailViewController *detail = [storyBoard instantiateInitialViewController];
            detail.selectedAppointment = currentAppointment;
            [self.navigationController pushViewController:detail animated:true];        }
    }
    else {
        currentAppointment = [model_manager.appointment_Manager.arrayNewRequests objectAtIndex:indexPath.row];
        
        if (currentAppointment) {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setValue:currentAppointment.apt_id forKey:@"apt_id"];
            [tempDict setValue:@"accepted" forKey:@"apt_status"];
            [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [model_manager.notificationManager notifiyClientAppointmentRequestAccepted:currentAppointment.user_id appointmentID:currentAppointment.apt_id];
                    [self getAppointmentsList];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Accepted Successfully."] animated:YES completion:nil];
                }
                else{
                    [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
                }
            }];
        }
    }
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
