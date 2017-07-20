//
//  PaymentSucessViewController.m
//  LiveVetNow
//
//  Created by Apple on 27/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "PaymentSucessViewController.h"
#import "UpcomingMeetingsViewController.h"
#import "EmailDetailViewController.h"
@interface PaymentSucessViewController ()
{
    
    IBOutlet UILabel *doctorName;
    
}

@end

@implementation PaymentSucessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    doctorName.text = self.currentVet.name.capitalizedString;
}
- (IBAction)btnSendMessageAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
    EmailDetailViewController *objEmailDetail = [storyboard instantiateViewControllerWithIdentifier:@"EmailDetailVC"];
    objEmailDetail.fromPaymentSuccess = true;

    objEmailDetail.receiverId = self.currentVet.vetId;
    objEmailDetail.receiverName = self.currentVet.name;
    [self.navigationController pushViewController:objEmailDetail animated:true];
   
}
- (IBAction)btnMyMeetingsAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UpcomingMeetings" bundle:nil];
    UpcomingMeetingsViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"upcomingMeetingViewController"];
    objPetListing.fromPaymentSuccess = true;
    [self.navigationController pushViewController:objPetListing animated:true];
}
- (IBAction)btnBakcAction:(id)sender {
    
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
