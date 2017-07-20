//
//  ReviewViewController.m
//  LiveVetNow
//
//  Created by Apple on 31/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "ReviewViewController.h"
#import "PayPalConfiguration.h"
#import "PayPalMobile.h"
#import "Constants.h"
#import "StartCallViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "PaymentSucessViewController.h"
@interface ReviewViewController () {
    
    __weak IBOutlet UIImageView *imgViewVet;
    __weak IBOutlet UILabel *lblVetName;
    __weak IBOutlet UIButton *btnVetLocation;
}

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation ReviewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
}

-(void)loadData {
    [btnVetLocation setTitle:self.currentVet.state forState:UIControlStateNormal];
    [imgViewVet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,self.currentVet.image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewVet.image = image;
        else
            imgViewVet.image = [UIImage imageNamed:@"DummyProfile"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    lblVetName.text =  self.currentVet.name;
}

- (IBAction)btnConfirmAndPayAction:(UIButton *)sender {
    [self setupPaypalConfig];
}
- (IBAction)btnBackAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}

-(void)setupPaypalConfig
{
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = NO;
    _payPalConfig.merchantName = @"vikisingla1992-facilitator@gmail.com";
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
            
            [tempDict setValue:self.appointmentID forKey:@"apt_id"];
            [tempDict setValue:@"confirmed" forKey:@"apt_status"];
            [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
            [model_manager.appointment_Manager setAppointmentStatus:tempDict withCompletionBlock:^(BOOL success, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                  //  [model_manager.notificationManager notifiyVetAppointmentRequestConfirmed:self.currentVet.vetId appointmentID:self.appointmentID];
                    
                    if ([self.appointmentType isEqualToString:@"emergency"])
                    {
                        [self moveToReadyCallScreen];

                    }
                    else{
                        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ReviewAndPay" bundle:nil];
                        PaymentSucessViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"paymentSuccessVC"];
                        obj.currentVet = self.currentVet;
                        [self.navigationController pushViewController:obj animated:true];
                        
                    }
              
                }
                else{
                    [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
                }
            }];
        }
    }
}

-(void)moveToReadyCallScreen {
    UIStoryboard *startCallStoryboard = [UIStoryboard storyboardWithName:@"StartCall" bundle:nil];
    StartCallViewController *objStartCallVC = [startCallStoryboard instantiateViewControllerWithIdentifier:@"startCallVC"];
    objStartCallVC.appointmentID = self.appointmentID;
    objStartCallVC.currentVet = self.currentVet;
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController pushViewController:objStartCallVC animated:true];
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
