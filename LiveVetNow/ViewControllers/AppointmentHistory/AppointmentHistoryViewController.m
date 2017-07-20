//
//  AppointmentHistoryViewController.m
//  LiveVetNow
//
//  Created by Apple on 10/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "AppointmentHistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "UIImageView+Customization.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "Appointment.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIView+Customization.h"
#import "KLCPopup.h"

@interface AppointmentHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UIView *viewPopUp;
    KLCPopup* popup;

    IBOutlet UITextView *txtViewNotesText;
    IBOutlet UILabel *lblPetName;
    IBOutlet UITableView *tblViewHistory;
}

@end

@implementation AppointmentHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.appointment_Manager getAppointmentHistory:nil withCompletionBlock:^(BOOL success, NSString *message)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         if (success) {
             
             [tblViewHistory reloadData];
             
         }
         else{
             [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
         }
         
     }];
    tblViewHistory.tableFooterView = [[UIView alloc] init];
    viewPopUp = [UIView addShadowToView:viewPopUp];
    viewPopUp.hidden = true;
    popup= [KLCPopup popupWithContentView:viewPopUp showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];

    viewPopUp.layer.cornerRadius = 5;
    viewPopUp.clipsToBounds = true;
        
}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - table view delegates and datasources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model_manager.appointment_Manager.arrayAppointmentsHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryTableViewCell *historyListingCell = (HistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    Appointment *obj  = (Appointment*)[model_manager.appointment_Manager.arrayAppointmentsHistory objectAtIndex:indexPath.row];
    historyListingCell.imgViewSender = [UIImageView roundImageViewWithBorderColourWithImageView:historyListingCell.imgViewSender withColor:[UIColor lightGrayColor]];
    if (kAppDelegate.isVet)
    {
    historyListingCell.lblName.text = obj.user_name;
    historyListingCell.lblDateTime.text = [NSString stringWithFormat:@"%@ %@", obj.appointmentDate,obj.appointmentTime];
       
        [historyListingCell.imgViewSender sd_setImageWithURL:[NSURL URLWithString:obj.user_image_url] placeholderImage: [UIImage imageNamed:@"DummyProfile"]];
       
    }
    else{
      
        historyListingCell.lblName.text = obj.doctor_name;
        historyListingCell.lblDateTime.text = [NSString stringWithFormat:@"%@ %@", obj.appointmentDate,obj.appointmentTime];
        [historyListingCell.imgViewSender sd_setImageWithURL:[NSURL URLWithString:obj.doctor_image_url] placeholderImage: [UIImage imageNamed:@"DummyProfile"]];

        
    }
    

 //   Email *currentEmail = [model_manager.emailManager.arrayEmails objectAtIndex:indexPath.row];
    
       return historyListingCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}
- (IBAction)btnViewNotesAction:(UIButton*)sender {
    
    viewPopUp.hidden = false;
    [popup show];
    HistoryTableViewCell *historyListingCell =(HistoryTableViewCell*) sender.superview.superview;
   
    NSIndexPath *index = [tblViewHistory indexPathForCell:historyListingCell];
    Appointment *obj  = (Appointment*)[model_manager.appointment_Manager.arrayAppointmentsHistory objectAtIndex:index.row];

    lblPetName.text = obj.pet_name;
    txtViewNotesText.text = obj.notes;

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
