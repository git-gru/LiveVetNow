//
//  MeetingDetailViewController.m
//  LiveVetNow
//
//  Created by Apple on 03/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "MeetingDetailViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "ReviewViewController.h"
#import "EmailDetailViewController.h"
#import "StartCallViewController.h"

@interface MeetingDetailViewController ()<UITableViewDelegate,UITableViewDataSource,AppointmentManagerDelegate> {
    
    IBOutlet UIView *viewHeader; // background color to change during doc
    IBOutlet UIView *viewMeetingDetails;// background color to change during doc
    IBOutlet UIButton *btnCancelRequest; // show/hide
    IBOutlet UIButton *btnPayNow;
    IBOutlet UIImageView *imgViewPetPic;
    IBOutlet UIButton *btnMeetingTime;
    IBOutlet UIButton *btnMeetingDate;
    IBOutlet UILabel *lblPetDetails;
    IBOutlet UIButton *btnLocation;
    IBOutlet UIButton *btnMeetingStatus;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPetName;
    IBOutlet UIImageView *imgViewProfilePic;
    NSMutableArray *arrayQues;
    NSMutableArray *arrayAns;
    IBOutlet UITableView *tblViewQuestions;
}

@end

@implementation MeetingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    model_manager.appointment_Manager.appointmentDelegate = self;
    [self loadViews];
    tblViewQuestions.tableFooterView = [[UIView alloc]init];
}

-(void)fetchedAppointmentList {
    [self loadViews];
}

-(void)loadViews {
    arrayQues = [[NSMutableArray alloc]initWithObjects:@"WHAT IS THE PROBLEM?",@"FROM HOW LONG ITS HAPPENING?", nil];
    arrayAns = [NSMutableArray new];
    if (self.selectedAppointment.ques_answers.count>0) {
        for (id object in self.selectedAppointment.ques_answers) {
            if ([[object valueForKey:@"ques_id"] isEqualToString:@"1"]) {
                [arrayAns insertObject:[object valueForKey:@"answer"] atIndex:0];
            }
            else if ([[object valueForKey:@"ques_id"] isEqualToString:@"2"]) {
                [arrayAns insertObject:[object valueForKey:@"answer"] atIndex:1];
            }
            else if ([[object valueForKey:@"ques_id"] isEqualToString:@"3"]) {
                [arrayAns insertObject:[object valueForKey:@"answer"] atIndex:2];
            }
        }
    }
    
    tblViewQuestions.estimatedRowHeight = 90;
    tblViewQuestions.rowHeight = UITableViewAutomaticDimension;
    [self loadData];
}

-(void)loadData {
    [btnMeetingTime setTitle:self.selectedAppointment.appointmentTime forState:UIControlStateNormal];
    [btnMeetingDate setTitle:self.selectedAppointment.appointmentDate forState:UIControlStateNormal];
    [imgViewPetPic setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,self.selectedAppointment.pet_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewPetPic.image = image;
        else
            imgViewPetPic.image = [UIImage imageNamed:@"dummyDog"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    lblPetName.text =  self.selectedAppointment.pet_name;
    
    if ([self.selectedAppointment.appointment_status isEqualToString:@"pending"]) {
        if (kAppDelegate.isVet) {
            btnCancelRequest.hidden = NO;
            viewMeetingDetails.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:68.0/255.0 blue:204.0/255.0 alpha:1];
            viewHeader.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:82.0/255.0 blue:227.0/255.0 alpha:1];
            btnPayNow.hidden = NO;
            [btnCancelRequest setTitle:@"REJECT" forState:UIControlStateNormal];
            btnCancelRequest.layer.borderWidth = 1.0f;
            btnCancelRequest.layer.borderColor = [UIColor blackColor].CGColor;
            [btnCancelRequest setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnCancelRequest.backgroundColor = [UIColor whiteColor];
            [btnPayNow setTitle:@"ACCEPT" forState:UIControlStateNormal];
            [btnPayNow setBackgroundColor:[UIColor colorWithRed:10.0/255.0 green:68.0/255.0 blue:204.0/255.0 alpha:1]];
            
        }
        else {
            btnCancelRequest.hidden = NO;
            btnPayNow.hidden = YES;
            viewMeetingDetails.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:68.0/255.0 blue:204.0/255.0 alpha:1];
            viewHeader.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:82.0/255.0 blue:227.0/255.0 alpha:1];
            [btnCancelRequest setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
            btnCancelRequest.layer.borderWidth = 1.0f;
            btnCancelRequest.layer.borderColor = [UIColor blackColor].CGColor;
            [btnCancelRequest setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnCancelRequest.backgroundColor = [UIColor whiteColor];
            
        }
    }
    else if ([self.selectedAppointment.appointment_status isEqualToString:@"accepted"]) {
        if (kAppDelegate.isVet) {
            btnCancelRequest.hidden = NO;
            btnPayNow.hidden = YES;
            [btnCancelRequest setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
        }
        else {
            btnCancelRequest.hidden = NO;
            btnPayNow.hidden = NO;
            [btnCancelRequest setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
            [btnPayNow setTitle:@"PAY NOW" forState:UIControlStateNormal];
        }
    }
    else if ([self.selectedAppointment.appointment_status isEqualToString:@"confirmed"]) {
        if (kAppDelegate.isVet) {
            btnCancelRequest.hidden = YES;
            btnPayNow.hidden = NO;
            [btnPayNow setTitle:@"SEND MESSAGE" forState:UIControlStateNormal];
        }
        else {
            btnCancelRequest.hidden = NO;
            btnPayNow.hidden = NO;
            [btnCancelRequest setTitle:@"CALL" forState:UIControlStateNormal];
            [btnPayNow setTitle:@"SEND MESSAGE" forState:UIControlStateNormal];
        }
    }
    else {
        btnCancelRequest.hidden = YES;
        btnPayNow.hidden = YES;
    }
    
    if (kAppDelegate.isVet) {
        btnMeetingStatus.hidden = YES;
        lblName.text = self.selectedAppointment.user_name;
        btnLocation.hidden = YES;
        [imgViewProfilePic setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,self.selectedAppointment.user_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                imgViewProfilePic.image = image;
            else
                imgViewProfilePic.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        btnMeetingStatus.hidden = NO;
        [btnMeetingStatus setTitle:[self.selectedAppointment.appointment_status capitalizedString]forState:UIControlStateNormal];
        lblName.text = self.selectedAppointment.doctor_name;
        btnLocation.hidden = NO;
        [btnLocation setTitle:self.selectedAppointment.doctor_state forState:UIControlStateNormal];
        [imgViewProfilePic setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,self.selectedAppointment.doctor_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                imgViewProfilePic.image = image;
            else
                imgViewProfilePic.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    lblPetDetails.text = [NSString stringWithFormat:@"%@-%@-%@MONTHS",[self.selectedAppointment.pet_type capitalizedString],[self.selectedAppointment.pet_sex capitalizedString],[self.selectedAppointment.pet_age capitalizedString]];
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayQues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *customQuesCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"meetingDetailQuestionsCell"];
    UILabel *labelQues = [customQuesCell.contentView viewWithTag:1];
    labelQues.text = [arrayQues objectAtIndex:indexPath.row];
    
    UILabel *labelAnswer = [customQuesCell.contentView viewWithTag:2];
    if (arrayAns.count>indexPath.row)
        labelAnswer.text = [arrayAns objectAtIndex:indexPath.row];
    else
        labelAnswer.text = @"";
    return  customQuesCell;
}

- (IBAction)btnPayNowAction:(id)sender {
    if ([self.selectedAppointment.appointment_status isEqualToString:@"pending"]) {
        if (kAppDelegate.isVet) {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setValue:self.selectedAppointment.apt_id forKey:@"apt_id"];
            [tempDict setValue:@"accepted" forKey:@"apt_status"];
            [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [model_manager.notificationManager notifiyClientAppointmentRequestAccepted:self.selectedAppointment.user_id appointmentID:self.selectedAppointment.apt_id];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Accepted Successfully."] animated:YES completion:nil];
                }
                else{
                    [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
                }
            }];
        }
    }
    else if ([self.selectedAppointment.appointment_status isEqualToString:@"accepted"]) {
        if (!kAppDelegate.isVet) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ReviewAndPay" bundle:nil];
            ReviewViewController *obj = [storyboard instantiateInitialViewController];
            obj.currentVet = [[Vet alloc]init];
            obj.appointmentID = self.selectedAppointment.apt_id;
            obj.currentVet.vetId = self.selectedAppointment.doctor_id;
            obj.currentVet.name =self.selectedAppointment.doctor_name;
            obj.currentVet.image_url =self.selectedAppointment.doctor_image_url;
            obj.currentVet.name =self.selectedAppointment.doctor_name;
            obj.currentVet.state =self.selectedAppointment.doctor_state;
            obj.currentVet.speciality_name =self.selectedAppointment.doctor_speciality;
            [self.navigationController pushViewController:obj animated:true];
        }
    }
    else if ([self.selectedAppointment.appointment_status isEqualToString:@"confirmed"]) {
        if (kAppDelegate.isVet) {
            [self sendMessageTo:self.selectedAppointment.user_name userId:self.selectedAppointment.user_id];
        }
        else {
            [self sendMessageTo:self.selectedAppointment.doctor_name userId:self.selectedAppointment.doctor_id];
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

- (IBAction)btnCancelRequestAction:(id)sender {
    if ([self.selectedAppointment.appointment_status isEqualToString:@"pending"]) {
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setValue:self.selectedAppointment.apt_id forKey:@"apt_id"];
        [tempDict setValue:@"cancelled" forKey:@"apt_status"];
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        if (kAppDelegate.isVet) {
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [model_manager.notificationManager notifiyClientAppointmentRequestRejected:self.selectedAppointment.user_id appointmentID:self.selectedAppointment.apt_id];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Rejected Successfully."] animated:YES completion:nil];
                }
                else{
                    [kAppDelegate showAlert:message];
                }
            }];
        }
        else {
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [model_manager.notificationManager notifiyAppointmentRequestCancelled:self.selectedAppointment.doctor_id appointmentID:self.selectedAppointment.apt_id];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Cancelled Successfully."] animated:YES completion:nil];
                }
                else{
                    [kAppDelegate showAlert:message];
                }
            }];
        }
    }
    else if ([self.selectedAppointment.appointment_status isEqualToString:@"accepted"]) {
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setValue:self.selectedAppointment.apt_id forKey:@"apt_id"];
        [tempDict setValue:@"cancelled" forKey:@"apt_status"];
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        if (kAppDelegate.isVet) {
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [model_manager.notificationManager notifiyAppointmentRequestCancelled:self.selectedAppointment.user_id appointmentID:self.selectedAppointment.apt_id];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Cancelled Successfully."] animated:YES completion:nil];
                }
                else{
                    [kAppDelegate showAlert:message];
                }
            }];
        }
        else {
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [model_manager.notificationManager notifiyAppointmentRequestCancelled:self.selectedAppointment.doctor_id appointmentID:self.selectedAppointment.apt_id];
                    [self presentViewController:[kAppDelegate showAlert:@"Appointment Cancelled Successfully."] animated:YES completion:nil];
                }
                else{
                    [kAppDelegate showAlert:message];
                }
            }];
        }
    }
    else if ([self.selectedAppointment.appointment_status isEqualToString:@"confirmed"]) {
        if (!kAppDelegate.isVet) {
            [self call];
/*
            if ( [[model_manager.appointment_Manager timestampFromDate:[NSDate date]] doubleValue]-[self.selectedAppointment.appointment_datetime doubleValue]  < 1800 && [[model_manager.appointment_Manager timestampFromDate:[NSDate date]] doubleValue]-[self.selectedAppointment.appointment_datetime doubleValue]  > 0) {
                [self call];
            }
            else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please call the doctor at the time of appointment." preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    // Cancel button tappped.
                    [alert dismissViewControllerAnimated:true completion:nil];
                    
                }]];
                
                [self presentViewController:alert animated:true completion:nil];

                
            }
 */
        }
    }
}

-(void) call {
    
    UIStoryboard *signupStoryboard = [UIStoryboard storyboardWithName:@"StartCall" bundle:nil];
    StartCallViewController *objStartCallVC = [signupStoryboard instantiateViewControllerWithIdentifier:@"startCallVC"];
    objStartCallVC.appointmentID = self.selectedAppointment.apt_id;
    
    Vet *vetObj = [[Vet alloc]init];
    
    vetObj.vetId = self.selectedAppointment.doctor_id;
    vetObj.name = self.selectedAppointment.doctor_name;
    vetObj.state = self.selectedAppointment.doctor_state;
    
    objStartCallVC.currentVet = vetObj;
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController pushViewController:objStartCallVC animated:true];
    
    
}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
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
