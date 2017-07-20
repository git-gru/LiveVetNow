//
//  UpcomingMeetingsViewController.m
//  LiveVetNow
//
//  Created by Apple on 24/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "UpcomingMeetingsViewController.h"
#import "UpcomingMeetingsTableViewCell.h"
#import "Constants.h"
#import "Appointment.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MeetingDetailViewController.h"
@interface UpcomingMeetingsViewController () {
    __weak IBOutlet UITableView *tableViewClientMeetings;
    
}

@end

@implementation UpcomingMeetingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableViewClientMeetings.hidden = YES;
    [self getAppointmentsList];
}

-(void)getAppointmentsList {
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.appointment_Manager getAppointmentsList:nil withCompletionBlock:^(BOOL success, NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            if(model_manager.appointment_Manager.arrayAppointments.count>0) {
                tableViewClientMeetings.hidden = NO;
                [tableViewClientMeetings reloadData];
            }
            else {
                tableViewClientMeetings.hidden = YES;
                [tableViewClientMeetings reloadData];
            }
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model_manager.appointment_Manager.arrayAppointments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UpcomingMeetingsTableViewCell *customListingCell = (UpcomingMeetingsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomUpcomingMeetingCell];
    
    Appointment *currentAppointment;
    currentAppointment = [model_manager.appointment_Manager.arrayAppointments objectAtIndex:indexPath.row];
    
    if (currentAppointment) {
        [customListingCell.imgViewVet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentAppointment.doctor_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                customListingCell.imgViewVet.image = image;
            else
                customListingCell.imgViewVet.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        customListingCell.lblVetName.text = currentAppointment.doctor_name;
        [customListingCell.btnVetLocation setTitle:currentAppointment.doctor_state forState:UIControlStateNormal];
        [customListingCell.btnDate setTitle:currentAppointment.appointmentDate forState:UIControlStateNormal];
        [customListingCell.btnTime setTitle:currentAppointment.appointmentTime forState:UIControlStateNormal];
        
        customListingCell.lblPetName.text = currentAppointment.pet_name;
        [customListingCell.imgViewPet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentAppointment.pet_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                customListingCell.imgViewPet.image = image;
            else
                customListingCell.imgViewPet.image = [UIImage imageNamed:@"dummyDog"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        customListingCell.lblPetInfo.text = [NSString stringWithFormat:@"%@-%@-%@MONTHS",[currentAppointment.pet_type capitalizedString],[currentAppointment.pet_sex capitalizedString],[currentAppointment.pet_age capitalizedString]];
        
        [customListingCell.btnViewDetail addTarget:self action:@selector(appointmentViewDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [customListingCell.btnCancel addTarget:self action:@selector(appointmentCancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if ([currentAppointment.appointment_status isEqualToString:@"accepted"]) {
            customListingCell.btnStatus.hidden = NO;
            [customListingCell.btnStatus setTitle:@"ACCEPTED" forState:UIControlStateNormal];
            [customListingCell.btnStatus setTitleColor:[UIColor colorWithRed:35.0/255.0 green:192.0/255.0 blue:104.0/255.0 alpha:1] forState:UIControlStateNormal];

            [customListingCell.btnStatus setImage:[UIImage imageNamed:@"GreenTick"] forState:UIControlStateNormal];

            customListingCell.btnCancel.hidden = NO;
            customListingCell.btnViewDetail.hidden = NO;
        }
        else if ([currentAppointment.appointment_status isEqualToString:@"cancelled"]) {
            customListingCell.btnStatus.hidden = NO;
            [customListingCell.btnStatus setTitle:@"CANCELLED" forState:UIControlStateNormal];
            [customListingCell.btnStatus setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [customListingCell.btnStatus setImage:nil forState:UIControlStateNormal];

            customListingCell.btnCancel.hidden = YES;
            customListingCell.btnViewDetail.hidden = YES;
        }
        else if ([currentAppointment.appointment_status isEqualToString:@"confirmed"]) {
            customListingCell.btnStatus.hidden = NO;
            [customListingCell.btnStatus setTitle:@"CONFIRMED" forState:UIControlStateNormal];
            [customListingCell.btnStatus setImage:[UIImage imageNamed:@"GreenTick"] forState:UIControlStateNormal];
            [customListingCell.btnStatus setTitleColor:[UIColor colorWithRed:35.0/255.0 green:192.0/255.0 blue:104.0/255.0 alpha:1] forState:UIControlStateNormal];

            customListingCell.btnCancel.hidden = NO;
            customListingCell.btnViewDetail.hidden = NO;
        }
        else {
            customListingCell.btnStatus.hidden = NO;
            [customListingCell.btnStatus setTitle:@"WAITING" forState:UIControlStateNormal];
            [customListingCell.btnStatus setImage:nil forState:UIControlStateNormal];
            [customListingCell.btnStatus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

            customListingCell.btnCancel.hidden = NO;
            customListingCell.btnViewDetail.hidden = NO;
        }
    }
    return customListingCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Appointment *currentAppointment;
    currentAppointment = [model_manager.appointment_Manager.arrayAppointments objectAtIndex:indexPath.row];
    if (currentAppointment) {
        if (![currentAppointment.appointment_status isEqualToString:@"cancelled"]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MeetingDetail" bundle:nil];
            MeetingDetailViewController *detail = [storyBoard instantiateInitialViewController];
            detail.selectedAppointment = currentAppointment;
            [self.navigationController pushViewController:detail animated:true];
        }
    }
}

-(void)appointmentViewDetailButtonAction:(UIButton*)sender {
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewClientMeetings];
    NSIndexPath *indexPath = [tableViewClientMeetings indexPathForRowAtPoint:rootViewPoint];
    Appointment *currentAppointment;
    currentAppointment = [model_manager.appointment_Manager.arrayAppointments objectAtIndex:indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MeetingDetail" bundle:nil];
    MeetingDetailViewController *detail = [storyBoard instantiateInitialViewController];
    detail.selectedAppointment = currentAppointment;
    [self.navigationController pushViewController:detail animated:true];
}

-(void)appointmentCancelButtonAction:(UIButton*)sender {
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewClientMeetings];
    NSIndexPath *indexPath = [tableViewClientMeetings indexPathForRowAtPoint:rootViewPoint];
    
    Appointment *currentAppointment;
    currentAppointment = [model_manager.appointment_Manager.arrayAppointments objectAtIndex:indexPath.row];
    if (currentAppointment) {
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setValue:currentAppointment.apt_id forKey:@"apt_id"];
        [tempDict setValue:@"cancelled" forKey:@"apt_status"];
        [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                [model_manager.notificationManager notifiyAppointmentRequestCancelled:currentAppointment.doctor_id appointmentID:currentAppointment.apt_id];
                [self getAppointmentsList];
                [self presentViewController:[kAppDelegate showAlert:@"Appointment Cancelled Successfully."] animated:YES completion:nil];
            }
            else {
                [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
            }
        }];
    }
}

- (IBAction)btnBackAction:(id)sender {
    if (_fromPaymentSuccess)
    {
        
        [self.navigationController popToRootViewControllerAnimated:true];
    }
    else{
    [self.navigationController popViewControllerAnimated:true];
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
