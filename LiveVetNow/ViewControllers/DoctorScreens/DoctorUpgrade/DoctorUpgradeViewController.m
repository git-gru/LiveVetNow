//
//  DoctorUpgradeViewController.m
//  LiveVetNow
//
//  Created by Apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "DoctorUpgradeViewController.h"
#import "PayPalConfiguration.h"
#import "Constants.h"
#import "PayPalMobile.h"
#import "MBProgressHUD.h"
#import "ViewController.h"
@interface DoctorUpgradeViewController ()<PayPalPaymentDelegate>
{
    
    NSDictionary *dictSessionData;
}
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation DoctorUpgradeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"callStarted" object:nil];

}
- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
    

}
-(void)notificationReceived:(NSNotification *)notification {
    
    
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

- (IBAction)upgradeButtonAction:(id)sender {
    
    [self setupPaypalConfig];
}



-(void)setupPaypalConfig
{
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = NO;
    _payPalConfig.merchantName = @"simransingh0232-facilitator@gmail.com";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    // use default environment, should be Production in real life
    
    [PayPalMobile preconnectWithEnvironment:kPayPalEnvironment];
    
    [self paymentToPaypal];
    
}

-(void)paymentToPaypal
{
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [NSDecimalNumber decimalNumberWithString:@"49.00"];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Doctor Appointment Charges";
    payment.items = nil;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = nil; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
        
        NSLog(@"problem");
    }
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalConfig delegate:self];
    
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    //    [self showSuccess];
    
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    // self.resultText = nil;
    // self.successView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
  
    NSMutableDictionary *confirmationDict = [completedPayment.confirmation mutableCopy];
    if (confirmationDict) {
        if ([[[confirmationDict objectForKey:@"response"] objectForKey:@"state"] isEqualToString:@"approved"]) {
            
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setValue:completedPayment.amount forKey:@"txn_amount"];
            [tempDict setValue:completedPayment.currencyCode forKey:@"currency"];
            [tempDict setValue:[[confirmationDict objectForKey:@"response"] objectForKey:@"id"] forKey:@"txn_id"];
            [tempDict setValue:[model_manager.appointment_Manager timestampFromDate:[model_manager.appointment_Manager getDateFromString:[[confirmationDict objectForKey:@"response"] objectForKey:@"create_time"]]] forKey:@"txn_datetime"];
            
            [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
            [model_manager.profileManager upgradeDoctorWithParams:tempDict handler:^(BOOL success, NSString *message)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:true];
                 if (success)
                 {
                     
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"You are now a recommended doctor in the users list." preferredStyle:UIAlertControllerStyleAlert];
                     
                     [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                         
                         // Cancel button tappped.
                         [alert dismissViewControllerAnimated:true completion:nil];
                         
                     }]];
                     
                     [self presentViewController:alert animated:true completion:nil];

                     
                 }
                 
             }];
            
        }
    
    }}


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
