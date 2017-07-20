//
//  ScheduleMeetingViewController.m
//  LiveVetNow
//
//  Created by Apple on 25/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "ScheduleMeetingViewController.h"
#import "Constants.h"
#import "KLCPopup.h"
#import "UIView+Customization.h"
#import "Pet.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UpcomingMeetingsViewController.h"
#define kcustomScheduleMeetingCellQues1Tag 10
#define kcustomScheduleMeetingCellAns1Tag 11
#define kcustomScheduleMeetingCellQues2Tag 12
#define kcustomScheduleMeetingCellAns2Tag 13
#define kcustomScheduleMeetingCellQues3Tag 14
#define kcustomScheduleMeetingCellAns3Tag 15

#define kcustomPetListingViewPopUpImageView 20
#define kcustomPetListingViewPopUpName 21
#define kcustomPetListingViewPopUpInfo 22

@interface ScheduleMeetingViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate> {
    IBOutlet UIView *viewPopUp;
    KLCPopup*popup;
    Pet *selectedPet;
    __weak IBOutlet UIImageView *imgViewVet;
    __weak IBOutlet UILabel *lblVetName;
    __weak IBOutlet UIButton *btnSpeciality;
    __weak IBOutlet UIButton *btnLocation;
    __weak IBOutlet UIImageView *imgViewSelectedPet;
    __weak IBOutlet UILabel *lblSelectedPetName;
    __weak IBOutlet UILabel *lblSelectedPetInfo;
    NSString *ans1;
    NSString *ans2;
    NSString *ans3;
    __weak IBOutlet UITableView *tableViewQues;
    __weak IBOutlet UITableView *tableViewPets;
    long selectedRow;
    NSDate *selectedDate;
    IBOutlet UIView *scheduleSuccessPopUp;
    
    IBOutlet UITextView *txtViewAnswerLong;
    IBOutlet UITextView *txtViewAnswerWhatsWrong;
    NSDate *seletedTime;
    
    IBOutlet UIButton *btnScheduleDate;
    IBOutlet UIButton *btnScheduleTime;
    IBOutlet UIView *viewDatePickerView;
    IBOutlet UIDatePicker *datePicker;
    NSDateFormatter *dateFormatter;
    KLCPopup *successKLCPopup;
    
}


@end

@implementation ScheduleMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadViews];
    selectedRow = 0;
    selectedPet = [model_manager.petManager.arrayPets objectAtIndex:0];
    txtViewAnswerLong.delegate = self;
    txtViewAnswerWhatsWrong.delegate = self;
    dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [datePicker setDate:[NSDate date]];
    [datePicker setMinimumDate:[[NSDate date] dateByAddingTimeInterval:900]];
    
    [datePicker setTimeZone:[NSTimeZone systemTimeZone]];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    viewDatePickerView.hidden = true;
    
    NSString *string = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:900]];
    
    NSArray * arrayStringComponents = [string componentsSeparatedByString:@" "];
   
    [btnScheduleDate setTitle:[arrayStringComponents objectAtIndex:0] forState:UIControlStateNormal];
   
    selectedDate = [dateFormatter dateFromString:string];
    
    selectedDate = [selectedDate dateByAddingTimeInterval:900];

    [btnScheduleTime setTitle:[arrayStringComponents objectAtIndex:1] forState:UIControlStateNormal];
    [viewDatePickerView setBackgroundColor:[UIColor lightGrayColor]];
    [self loadData];

}

-(void)loadViews {
    
   
}

-(void)viewDidAppear:(BOOL)animated
{
    popup= [KLCPopup popupWithContentView:viewPopUp showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    viewPopUp.layer.cornerRadius = 5;
    viewPopUp.clipsToBounds = true;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [popup dismiss:true];
    
    popup = nil;
    viewPopUp = nil;
}

-(void)loadData {
    [imgViewVet setImageWithURL:[NSURL URLWithString:self.selectedVet.image_url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewVet.image = image;
        else
            imgViewVet.image = [UIImage imageNamed:@"DummyProfile"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    lblVetName.text = self.selectedVet.name;
    [btnSpeciality setTitle:self.selectedVet.speciality_name forState:UIControlStateNormal];
    [btnLocation setTitle:self.selectedVet.state forState:UIControlStateNormal];
    
    
    
    if (selectedPet!= nil)
    {
    [imgViewSelectedPet setImageWithURL:[NSURL URLWithString:selectedPet.pet_image_url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewSelectedPet.image = image;
        else
            imgViewSelectedPet.image = [UIImage imageNamed:@"dummyDog"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    lblSelectedPetName.text = selectedPet.pet_name;
    lblSelectedPetInfo.text = [NSString stringWithFormat:@"%@-%@-%@MONTHS",[selectedPet.pet_type capitalizedString],[selectedPet.pet_sex capitalizedString],[selectedPet.pet_age capitalizedString]];
    }
}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnRequestInvitationAction:(id)sender {
    UITableViewCell *customListingCell = (UITableViewCell*)[tableViewQues dequeueReusableCellWithIdentifier:kcustomScheduleMeetingCell];
   // UILabel *lblQues1 = (UILabel*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellQues1Tag];
    UITextView *txtViewAns1 = (UITextView*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellAns1Tag];
   // UILabel *lblQues2 = (UILabel*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellQues2Tag];
    UITextView *txtViewAns2 = (UITextView*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellAns2Tag];
    //UILabel *lblQues3 = (UILabel*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellQues3Tag];
    UITextView *txtViewAns3 = (UITextView*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellAns3Tag];
    [txtViewAns1 resignFirstResponder];
    [txtViewAns2 resignFirstResponder];
    [txtViewAns3 resignFirstResponder];
    if (ans1.length<=0) {
        [self presentViewController:[kAppDelegate showAlert:@"Please Answer All Questions"] animated:YES completion:nil];
        return;
    }
    if (ans2.length<=0) {
        [self presentViewController:[kAppDelegate showAlert:@"Please Answer All Questions"] animated:YES completion:nil];
        return;
    }
    /*
    if (ans3.length<=0) {
        [self presentViewController:[kAppDelegate showAlert:@"Please Answer All Questions"] animated:YES completion:nil];
        return;
    }
     */
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LiveVetNow", nil)  message:NSLocalizedString(@"Are you sure?", nil)  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self checkAvailabilityWithDate:datePicker.date bookingRequested : true];

    }];
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:ok];
    [alertController addAction:Cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)bookAppointment {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedVet.vetId,@"doctor_id",@"schedule",@"request_type",selectedPet.pet_id,@"vet_detail_id",@"aa",@"ques3",ans2,@"ques2",ans1,@"ques1",[model_manager.appointment_Manager timestampFromDate:selectedDate],@"apt_datetime",nil];
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.appointment_Manager bookAppointmentWithParams:params withHandler:^(BOOL success,NSString* appointmentID,NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
             [model_manager.notificationManager notifiyVetAppointmentRequest:self.selectedVet.vetId appointmentID:appointmentID];
            
           successKLCPopup= [KLCPopup popupWithContentView:scheduleSuccessPopUp showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
            [scheduleSuccessPopUp setHidden:false];
            [successKLCPopup show];
           // [self showAlert:@"Appointment Booked Successfully."];
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
}

- (void)showAlert:(NSString*)string {
UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:true];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)btnViewStatusAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UpcomingMeetings" bundle:nil];
    UpcomingMeetingsViewController *upcomingMeetings = [storyboard instantiateViewControllerWithIdentifier:@"upcomingMeetingViewController"];
    [self.navigationController pushViewController:upcomingMeetings animated:true];
    [successKLCPopup dismiss:true];

}
- (IBAction)btnCrossAction:(id)sender {
    [successKLCPopup dismiss:true];
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1)
        return 1;
    else
        return model_manager.petManager.arrayPets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        UITableViewCell *customListingCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomScheduleMeetingCell];
        UIView *viewBorder = [customListingCell.contentView viewWithTag:2];
        viewBorder = [UIView addShadowToView:viewBorder];
        
        UITextView *txtViewAns1 = (UITextView*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellAns1Tag];
        txtViewAns1.delegate = self;
        UITextView *txtViewAns2 = (UITextView*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellAns2Tag];
        txtViewAns2.delegate = self;
        UITextView *txtViewAns3 = (UITextView*)[customListingCell.contentView viewWithTag:kcustomScheduleMeetingCellAns3Tag];
        
        txtViewAns3.delegate = self;
        return customListingCell;
    }
    else {
        UITableViewCell *viewPopUpCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomPetListingViewPopUp];
        Pet *currentPet;
        currentPet = [model_manager.petManager.arrayPets objectAtIndex:indexPath.row];
        UIImageView *imgView = (UIImageView*)[viewPopUpCell.contentView viewWithTag:kcustomPetListingViewPopUpImageView];
        UILabel *lblPetName = (UILabel*)[viewPopUpCell.contentView viewWithTag:kcustomPetListingViewPopUpName];
        UILabel *lblPetInfo = (UILabel*)[viewPopUpCell.contentView viewWithTag:kcustomPetListingViewPopUpInfo];
        UIButton *btnCheck = (UIButton*)[viewPopUpCell.contentView viewWithTag:111];
        btnCheck.layer.borderColor = [UIColor grayColor].CGColor;
        btnCheck.layer.borderWidth = 1.0f;
     if (selectedRow == indexPath.row) {
            btnCheck.selected = true;
        }
        else{
            btnCheck.selected = false;
        }
        [imgView setImageWithURL:[NSURL URLWithString:currentPet.pet_image_url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                imgView.image = image;
            else
                imgView.image = [UIImage imageNamed:@"dummyDog"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        lblPetName.text = currentPet.pet_name;
        lblPetInfo.text = [NSString stringWithFormat:@"%@-%@-%@MONTHS",[currentPet.pet_type capitalizedString],[currentPet.pet_sex capitalizedString],[currentPet.pet_age capitalizedString]];
        return  viewPopUpCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == tableViewPets)
    {
        UITableViewCell *viewPopUpCell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *btnCheck = (UIButton*)[viewPopUpCell.contentView viewWithTag:111];
        if (btnCheck.isSelected)
        {
        btnCheck.selected = false;
            
        }
        else
        {
        btnCheck.selected= true;
            
            selectedRow = indexPath.row;
            [tableView reloadData];
            
        }
        
        selectedPet = [model_manager.petManager.arrayPets objectAtIndex:indexPath.row];
        
    }
}
    
- (IBAction)continueWithThisPet:(UIButton *)sender {
    [popup dismiss:true];
    [self loadData];
}

- (IBAction)btnContinueWithThisPetAction:(id)sender {
//    CGPoint center = ((UIButton*)sender).center;
//    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewPets];
//    NSIndexPath *indexPath = [tableViewPets indexPathForRowAtPoint:rootViewPoint];
//    selectedPet = [model_manager.petManager.arrayPets objectAtIndex:indexPath.row];
}



- (IBAction)btnChangePets:(id)sender {
    
    viewPopUp.hidden = NO;
    [popup show];
}

- (IBAction)btnChangeAction:(id)sender {
    viewPopUp.hidden = NO;
    [popup show];
}
- (IBAction)btnCancelAction:(UIButton *)sender {
    [popup dismiss:true];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (textView.tag == kcustomScheduleMeetingCellAns1Tag) {
        ans1 = textView.text;
    }
    if (textView.tag == kcustomScheduleMeetingCellAns2Tag) {
        ans2 = textView.text;
    }
    if (textView.tag == kcustomScheduleMeetingCellAns3Tag) {
        ans3 = textView.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 60;
}
    
- (IBAction)btnFixDateAppointment:(UIButton*)sender {
    viewDatePickerView.hidden = false;
}

- (IBAction)userSelectedDate:(UIDatePicker*)sender {
    
    selectedDate = sender.date;
    [self checkAvailabilityWithDate:sender.date bookingRequested : false];
    
   }


-(void)checkAvailabilityWithDate:(NSDate*)date bookingRequested:(BOOL)requested
{
    
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedVet.vetId,@"doctor_id",[model_manager.appointment_Manager timestampFromDate:selectedDate],@"appointment_datetime",nil];
        
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        [model_manager.appointment_Manager getDoctorAvailability:params withHandler:^(BOOL success,NSString* message) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                selectedDate = date;
                [btnScheduleDate setTitle:[model_manager.appointment_Manager getDateStringFromDate:selectedDate] forState:UIControlStateNormal];
                [btnScheduleTime setTitle:[model_manager.appointment_Manager getTimeStringFromDate:selectedDate] forState:UIControlStateNormal];
                if (requested)
                {
                    if([[dateFormatter dateFromString:[dateFormatter stringFromDate:date]] timeIntervalSinceDate:[dateFormatter dateFromString:[dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:800]]]] > 0 ) {
                    [self bookAppointment];
                    }
//                    else{
//                        
//                        
//                    }
                }
            }
            else {
               // [datePicker setDate:selectedDate];
                [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
            }
        }];
    

    
    
}
- (IBAction)btnDoneAction:(UIButton *)sender {
    viewDatePickerView.hidden = true;
    
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
