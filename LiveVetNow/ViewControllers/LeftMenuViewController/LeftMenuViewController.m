//
//  LeftMenuViewController.m
//  LiveVetNow
//
//  Created by Apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "LeftMenuTableViewCell.h"
#import "MFSideMenu.h"
#import "MFSideMenuContainerViewController.h"
#import "UIImageView+Customization.h"
#import "Constants.h"
#import "PetListingViewController.h"
#import "UpcomingMeetingsViewController.h"
#import "ScheduleMeetingViewController.h"
#import "PaymentSucessViewController.h"
#import "DoctorProfleEditViewController.h"
#import "MyPaymentsViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "EmailListingViewController.h"
#import "DoctorProfileVC.h"
#import "AppointmentHistoryViewController.h"
@interface LeftMenuViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *tblView;
    IBOutlet UILabel *emailLabel;
    IBOutlet UIImageView *imageViewProfile;
    NSMutableArray *leftMenuIcons;
    NSMutableArray *leftMenuTitles;
    IBOutlet UILabel *ownerNameLabel;
    NSString *notificationCount;
}

@end

@implementation LeftMenuViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageViewProfile = [UIImageView roundImageViewWithBorderColourWithImageView:imageViewProfile withColor:[UIColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    notificationCount= @"0";

    if (kAppDelegate.isVet)
    {
    leftMenuTitles = [NSMutableArray arrayWithObjects:@"HOME",@"MESSAGES",@"HISTORY",@"LOGOUT", nil];
        leftMenuIcons = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"Home"],[UIImage imageNamed:@"Message"],[UIImage imageNamed:@"History"],[UIImage imageNamed:@"Logout"], nil];

           ownerNameLabel.text = model_manager.profileManager.ownerVet.name.capitalizedString;
        [imageViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.ownerVet.image_url] placeholderImage:[UIImage imageNamed:@"DummyProfile" ]completed:nil];
     //   emailLabel.text = model_manager.profileManager.ownerVet.;


    }
    else{
  
        leftMenuIcons = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"Home"],[UIImage imageNamed:@"Paw"],[UIImage imageNamed:@"Calendar"],[UIImage imageNamed:@"Message"],[UIImage imageNamed:@"History"],[[UIImage alloc] init],[UIImage imageNamed:@"Settings"],[UIImage imageNamed:@"Logout"], nil];
           [imageViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.owner.profilePicUrl] placeholderImage:[UIImage imageNamed:@"DummyProfile" ] completed:nil];

        
        leftMenuTitles = [NSMutableArray arrayWithObjects:@"HOME",@"MY PETS",@"APPOINTMENTS",@"MESSAGES",@"HISTORY",@"",@"ACCOUNT",@"LOG OUT", nil];

        ownerNameLabel.text = model_manager.profileManager.owner.name.capitalizedString;
        emailLabel.text = model_manager.profileManager.owner.email;

        
    }
    
    
    [model_manager.appointment_Manager getAppointmentsList:nil withCompletionBlock:^(BOOL success, NSString *message) {
        if (success) {
         
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];

    
}

#pragma mark - tableview delegates

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return  [[UIView alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (kAppDelegate.isVet)
    {
        return 4;
    }
    else{
    
        return 8;
    
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *_simpleTableIdentifier = @"customLeftMenuCell";
    
    LeftMenuTableViewCell *_cell = (LeftMenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:_simpleTableIdentifier];
    
    _cell.labelTitle.text = [leftMenuTitles objectAtIndex:indexPath.row];
    
    
    _cell.imageViewProfile.image = [leftMenuIcons objectAtIndex:indexPath.row];
    if (!kAppDelegate.isVet)
    {
    if (indexPath.row == 5 )
    {
        _cell.viewSeparator.hidden = false;
    }
    else{
        
        _cell.viewSeparator.hidden = true;
        
        
    }
    }
    if (indexPath.row == 2 && !kAppDelegate.isVet)
    {
        
        _cell.btnNotificationCount.hidden = false;
        [_cell.btnNotificationCount setTitle:notificationCount forState:UIControlStateNormal];
    }
    else{
        
        _cell.btnNotificationCount.hidden = true;

    }
    
    
    
    return _cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {

            
           
        case 0: {
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            
            NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
            while (controllers.count>1) {
                [controllers removeLastObject];
            }
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            
        }
            break;
            
        case 1:
        {
            if (!kAppDelegate.isVet)
            {
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PetsListing" bundle:nil];
            PetListingViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"petListing"];
            NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
            while (controllers.count>1) {
                [controllers removeLastObject];
            }
            [controllers addObject:objPetListing];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
            else{
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
                EmailListingViewController *objEmailListing = [storyboard instantiateViewControllerWithIdentifier:@"EmailListingVC"];
                NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
                while (controllers.count>1) {
                    [controllers removeLastObject];
                }
                [controllers addObject:objEmailListing];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                
                
            }
        }
            break;
            
        case 2: {
            if (!kAppDelegate.isVet)
            {
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UpcomingMeetings" bundle:nil];
                UpcomingMeetingsViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"upcomingMeetingViewController"];
                NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
                while (controllers.count>1) {
                    [controllers removeLastObject];
                }
                [controllers addObject:objPetListing];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
              
            }
            else{
                
                    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"History" bundle:nil];
                    AppointmentHistoryViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"AppointmentHistoryViewController"];
                    NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
                    while (controllers.count>1) {
                        [controllers removeLastObject];
                    }
                    [controllers addObject:obj];
                    navigationController.viewControllers = controllers;
                    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                    
            
            }
        }
            break;
            
        case 3: {
            if (!kAppDelegate.isVet)
            {
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
            EmailListingViewController *objEmailListing = [storyboard instantiateViewControllerWithIdentifier:@"EmailListingVC"];
            NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
            while (controllers.count>1) {
                [controllers removeLastObject];
            }
            [controllers addObject:objEmailListing];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
            else{
                
                [kAppDelegate logOut];

            }
            
            
        }
            break;
            
            
        case 4: {
            
            if (!kAppDelegate.isVet)
            {
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"History" bundle:nil];
                AppointmentHistoryViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"AppointmentHistoryViewController"];
                NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
                while (controllers.count>1) {
                    [controllers removeLastObject];
                }
                [controllers addObject:obj];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
         
            /*
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
            EmailListingViewController *objEmailListing = [storyboard instantiateViewControllerWithIdentifier:@"EmailListingVC"];
            NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
            while (controllers.count>1) {
                [controllers removeLastObject];
            }
            [controllers addObject:objEmailListing];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
             */
        }
            break;
        
        case 5 :
        {
            
        }
            break;
            
        case 6 :
        {
            if (!kAppDelegate.isVet)
            {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
            
            DoctorProfleEditViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"ProfileEdit"];
                
                
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
            while (controllers.count>1) {
                [controllers removeLastObject];
            }
            [controllers addObject:obj];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }

            
            
        }
            break;
            
            
        case 7:
        {
            [kAppDelegate logOut];
        }
            break;
            
        default:
            break;
    }
    /*
     if(indexPath.row==0)
     {
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     while (controllers.count>1) {
     [controllers removeLastObject];
     }
     navigationController.viewControllers = controllers;
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     
     else if(indexPath.row==1)
     {
     //MyOrbitsScreen *obj = [[MyOrbitsScreen alloc] initWithNibName:nil bundle:nil];
     MyOrbits *obj = [[MyOrbits alloc] initWithNibName:nil bundle:nil];
     
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     while (controllers.count>1) {
     [controllers removeLastObject];
     }
     [controllers addObject:obj];
     navigationController.viewControllers = controllers;
     //[navigationController pushViewController:obj animated:YES];
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     else if(indexPath.row==2)
     {
     OrbHistoryScreen *obj = [[OrbHistoryScreen alloc] initWithNibName:nil bundle:nil];
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     while (controllers.count>1) {
     [controllers removeLastObject];
     }
     [controllers addObject:obj];
     navigationController.viewControllers = controllers;
     //[navigationController pushViewController:obj animated:YES];
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     else if(indexPath.row==3)
     {
     InvitationScreen *obj = [[InvitationScreen alloc] initWithNibName:nil bundle:nil];
     obj.isFromSlideMenu = @"true";
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     
     [controllers addObject:obj];
     navigationController.viewControllers = controllers;
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     else if(indexPath.row==4)
     {
     //        SetLocation *obj = [[SetLocation alloc] initWithNibName:nil bundle:nil];
     ShowLocations *obj=[[ShowLocations alloc] initWithNibName:nil bundle:nil];
     //SendOrbContacts *obj=[[SendOrbContacts alloc] initWithNibName:nil bundle:nil];
     
     
     //obj.isFromSlideMenu = @"true";
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     while (controllers.count>1) {
     [controllers removeLastObject];
     }
     [controllers addObject:obj];
     navigationController.viewControllers = controllers;
     //[navigationController pushViewController:obj animated:YES];
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     
     else if(indexPath.row==5)
     {
     profileUpdateScreen *obj = [[profileUpdateScreen alloc] initWithNibName:nil bundle:nil];
     
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     while (controllers.count>1) {
     [controllers removeLastObject];
     }
     [controllers addObject:obj];
     navigationController.viewControllers = controllers;
     //[navigationController pushViewController:obj animated:YES];
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     else if(indexPath.row==6)
     {
     AboutOrbScreen *object = [[AboutOrbScreen alloc] initWithNibName:nil bundle:nil];
     object.fromView=@"leftmenu";
     
     UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
     
     NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
     while (controllers.count>1) {
     [controllers removeLastObject];
     }
     [controllers addObject:object];
     navigationController.viewControllers = controllers;
     //[navigationController pushViewController:object animated:YES];
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
     }
     else if(indexPath.row==7)
     {
     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Do you really want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
     alert.tag = 47;
     [alert show];
     //clear user defaults for login
     
     
     }
     
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     */
}

- (IBAction)btnEditProfileAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
    
    DoctorProfleEditViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"ProfileEdit"];
    if (kAppDelegate.isVet)
    {
        obj.editType = @"Doctor";
    }
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSMutableArray *controllers =[navigationController.viewControllers mutableCopy];
    while (controllers.count>1) {
        [controllers removeLastObject];
    }
    [controllers addObject:obj];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    if (kAppDelegate.isVet)
    {
        
        [imageViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.ownerVet.image_url] placeholderImage:[UIImage imageNamed:@"DummyProfile" ]completed:nil];
        ownerNameLabel.text = model_manager.profileManager.ownerVet.name.capitalizedString;
          emailLabel.text = model_manager.profileManager.ownerVet.email;


    }
    else{
        
        [imageViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.owner.profilePicUrl] placeholderImage:[UIImage imageNamed:@"DummyProfile" ] completed:nil];
        
        ownerNameLabel.text = model_manager.profileManager.owner.name.capitalizedString;
        emailLabel.text = model_manager.profileManager.owner.email;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"appointment_status CONTAINS[cd] %@",@"confirmed"];
        if ([model_manager.appointment_Manager.arrayAppointments filteredArrayUsingPredicate:predicate].count >0) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:2 inSection:0];
            notificationCount =[NSString stringWithFormat:@"%lu", (unsigned long)[model_manager.appointment_Manager.arrayAppointments filteredArrayUsingPredicate:predicate].count];
            [tblView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
            
        }

            }
    
    

    // ...
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
