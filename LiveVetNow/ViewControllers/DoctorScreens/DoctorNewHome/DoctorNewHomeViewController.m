//
//  DoctorNewHomeViewController.m
//  LiveVetNow
//
//  Created by Apple on 10/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "DoctorNewHomeViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "MFSideMenu.h"
#import "UIView+Customization.h"
#import "MyPaymentsViewController.h"
#import "DoctorHomeViewController.h"
#import "EmailListingViewController.h"
#import "DoctorProfileVC.h"
#import "UIImageView+Customization.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Constants.h"
#import "DoctorUpgradeViewController.h"
#import "MBProgressHUD.h"
@interface DoctorNewHomeViewController ()
{
    IBOutlet UIImageView *imgViewDummyProfile;
    
    IBOutlet UIButton *btnAppointmentCOunt;
    IBOutlet UIImageView *imgViewDot;
    IBOutlet UIView *viewMyProfile;
    IBOutlet UIView *viewAppointments;
    NSDictionary *dictSessionData;

    IBOutlet UIView *viewMyPayments;
    IBOutlet UIView *viewMessages;
}

@end

@implementation DoctorNewHomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imgViewDummyProfile = [UIImageView roundImageViewWithBorderColourWithImageView:imgViewDummyProfile withColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"callStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"appointmentRequest" object:nil];

    imgViewDot = [UIImageView roundImageViewWithBorderColourWithImageView:imgViewDot withColor:[UIColor clearColor]];
    viewMyProfile = [UIView addBorderToView:viewMyProfile];
    viewAppointments = [UIView addBorderToView:viewAppointments];
    viewMyPayments = [UIView addBorderToView:viewMyPayments];
    viewMessages = [UIView addBorderToView:viewMessages];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [imgViewDummyProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.ownerVet.image_url] placeholderImage:[UIImage imageNamed:@"DummyProfile" ] completed:nil];
    [self getAppointmentsList];

}
- (IBAction)btnMenuAction:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];

    
}

-(void)getAppointmentsList {
  
    [model_manager.appointment_Manager getAppointmentsList:nil withCompletionBlock:^(BOOL success, NSString *message) {
        if (success) {
            [btnAppointmentCOunt setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)model_manager.appointment_Manager.arrayNewRequests.count] forState:UIControlStateNormal] ;
            
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
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


- (IBAction)bigButtonsAction:(UIButton*)sender {
    switch (sender.tag) {
            
            
        case 1:{
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
            DoctorHomeViewController *payments = [storyboard instantiateViewControllerWithIdentifier:@"doctorHome"];
            
            [self.navigationController pushViewController:payments animated:YES];
            
        }
            break;
        case 2: {
           
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
            EmailListingViewController *objEmailListing = [storyboard instantiateViewControllerWithIdentifier:@"EmailListingVC"];
            [self.navigationController pushViewController:objEmailListing animated:YES];
        
        }
            break;
        case 3:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
            
            MyPaymentsViewController *payments = [storyboard instantiateViewControllerWithIdentifier:@"DoctorMyPayments"];

            [self.navigationController pushViewController:payments animated:YES];
            
            
        }
            break;
            
        case 4: {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
            DoctorProfileVC *doctorProfile = [storyboard instantiateViewControllerWithIdentifier:@"profileDoctor"];
            
            [self.navigationController pushViewController:doctorProfile animated:YES];
        }
            break;
            
        default:
            break;
    }
            
}
- (IBAction)becomeRecomendedBtnAction:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
    DoctorUpgradeViewController *obj =[storyBoard instantiateViewControllerWithIdentifier:@"DoctorUpgrade"];
    
    
    [self.navigationController pushViewController:obj animated:true];
}

- (IBAction)switchAction:(UISwitch*)sender {
    
    if (sender.isOn)
    {
        
        NSLog(@"available");

        [model_manager.profileManager updateAvailabilityStatus:@"active" WithHandler:^(BOOL success, NSString* message)
        {
            if (success)
            {
                
                
            }
            
        }];
        
    }
    else{
        
        [model_manager.profileManager updateAvailabilityStatus:@"inactive" WithHandler:^(BOOL success, NSString* message)
         {
             if (success)
             {
                 
                 
             }
             
         }];

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
