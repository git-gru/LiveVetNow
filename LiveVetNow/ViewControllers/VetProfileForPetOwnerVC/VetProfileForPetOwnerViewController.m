//
//  VetProfileForPetOwnerViewController.m
//  LiveVetNow
//
//  Created by apple on 16/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "VetProfileForPetOwnerViewController.h"
#import "Constants.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIButton+Customization.h"
#import "VetProfileTableViewCell.h"
#import "StartCallViewController.h"
#import "ScheduleMeetingViewController.h"
#import "MBProgressHUD.h"
#import "ReviewViewController.h"
#import "UIImageView+Customization.h"

@interface VetProfileForPetOwnerViewController ()<UITableViewDelegate,UITableViewDataSource> {
    __weak IBOutlet UIImageView *imgViewVetProfile;
    __weak IBOutlet UITableView *tblViewVetProfile;
    __weak IBOutlet UIButton *btnMessage;
    __weak IBOutlet UIButton *btnCall;
    __weak IBOutlet UIButton *btnSchedule;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIButton *btnMenu;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblSpeciality;
    __weak IBOutlet UILabel *lblLocation;
    NSString *appointmentID;

    IBOutlet UIView *imgViewDot;
}

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;


@end

//@property (weak, nonatomic) IBOutlet UIButton *btnVideoCall;
//@property (weak, nonatomic) IBOutlet UIButton *btnSchedule;
//@property (weak, nonatomic) IBOutlet UIButton *btnMessage;

@implementation VetProfileForPetOwnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    model_manager.vetManager.vetManagerDelegate = self;
    [self loadViews];
    tblViewVetProfile.estimatedRowHeight = 282;
    tblViewVetProfile.rowHeight = UITableViewAutomaticDimension;
    imgViewVetProfile = [UIImageView roundImageViewWithBorderColourWithImageView:imgViewVetProfile withColor:[UIColor whiteColor]];
    imgViewDot.layer.borderWidth = 1.0f;
    imgViewDot.layer.borderColor = [UIColor whiteColor].CGColor ;
    
    
}

#pragma mark Custom Methods
- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnMenuAction:(id)sender {

}

-(void)loadViews {
    btnMessage = [UIButton addBorderToButton:btnMessage withBorderColour:[UIColor whiteColor]];
    btnSchedule = [UIButton addBorderToButton:btnSchedule withBorderColour:[UIColor whiteColor]];
    btnCall.layer.cornerRadius = 5.0f;
    [self loadData];
}

-(void)loadData {
   
    [imgViewVetProfile setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,self.selectedVet.image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewVetProfile.image = image;
        else
            imgViewVetProfile.image = [UIImage imageNamed:@"DummyProfile"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    lblName.text = self.selectedVet.name;
    lblSpeciality.text = self.selectedVet.speciality_name;
    lblLocation.text = self.selectedVet.state;
    [self setCallButtonAccordingToStatus];
}

-(void)setCallButtonAccordingToStatus {
    if ([self.type isEqualToString:@"emergency"])
    {
    if ([self.selectedVet.vetStatus isEqualToString:@"Online"]) {
        [btnCall setImage:[UIImage imageNamed:@"VideoCall"] forState:UIControlStateNormal];
        btnCall.userInteractionEnabled = YES;
        imgViewDot.backgroundColor = [UIColor greenColor];
        btnCall.hidden = NO;
    }
    //Vet offline
    else {
        [btnCall setImage:[UIImage imageNamed:@"VideoCallWhite"] forState:UIControlStateNormal];
        imgViewDot.backgroundColor = [UIColor lightGrayColor];

                btnCall.userInteractionEnabled = NO;
                btnCall.hidden = YES;
    }
    }
    else{
        
        btnSchedule.hidden = false;
        btnCall.hidden = true;
        if ([self.selectedVet.vetStatus isEqualToString:@"Online"])
        {
        imgViewDot.backgroundColor = [UIColor greenColor];
        }
        else{
            
            imgViewDot.backgroundColor = [UIColor lightGrayColor];

        }

    }

}

#pragma mark Custom Button Methods

-(IBAction)videoCallButtonAction:(id)sender {
    /*
    if (kAppDelegate.isInternetReachable)//If Internet available
    {
    }
    else
        [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
     */
    if ([self.selectedVet.vetStatus isEqualToString:@"Online"]) {
        [self showAlert:@"Are you sure?"];
    }
    //Vet offline
    else {
        [self presentViewController:[kAppDelegate showAlert:@"Vet is currently Offline. Please schedule a Appointment at a later date and time"] animated:YES completion:nil];
    }
}

-(void)showAlert:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LiveVetNow", nil)  message:NSLocalizedString(message, nil)  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self bookEmergencyAppointment];

    }];
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:ok];
    [alertController addAction:Cancel];

    [self presentViewController:alertController animated:YES completion:nil];
}
    
    
-(void)bookEmergencyAppointment {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedVet.vetId,@"doctor_id",@"emergency",@"request_type",@"1",@"vet_detail_id",@"Answered",@"ques3",@"Answered",@"ques2",@"Answered",@"ques1",nil];
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        [model_manager.appointment_Manager bookAppointmentWithParams:params withHandler:^(BOOL success,NSString *Id,NSString *message) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                
                appointmentID = Id;
                
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ReviewAndPay" bundle:nil];
                ReviewViewController *obj = [storyboard instantiateInitialViewController];
                obj.appointmentType = @"emergency";
                obj.appointmentID = appointmentID;
                obj.currentVet = self.selectedVet;
                [self.navigationController pushViewController:obj animated:true];
                
                
            }
            else{
                [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
                [self showAlert:@""];
                
            }
            
        }];
        
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
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
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
}

-(void)moveToReadyCallScreen
{
    
    UIStoryboard *signupStoryboard = [UIStoryboard storyboardWithName:@"StartCall" bundle:nil];
    StartCallViewController *objStartCallVC = [signupStoryboard instantiateViewControllerWithIdentifier:@"startCallVC"];
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController pushViewController:objStartCallVC animated:true];
}



-(IBAction)scheduleButtonAction:(id)sender {
    /*
    if (kAppDelegate.isInternetReachable)//If Internet available
    {
    }
    else
        [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ScheduleMeeting" bundle:nil];
    ScheduleMeetingViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"schedule"];
    objPetListing.selectedVet = self.selectedVet;
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController pushViewController:objPetListing animated:true];
}

-(IBAction)messageButtonAction:(id)sender {
    if (kAppDelegate.isInternetReachable)//If Internet available
    {
    }
    else
        [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
       return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VetProfileTableViewCell *customProfileCell = (VetProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomProfileCell];
    
    customProfileCell.lblOverview.text = self.selectedVet.overview;
    
    
    if (self.selectedVet.review_details.count > 0)
        {
    customProfileCell.lblComment.text = [self.selectedVet.review_details objectForKey:@"review"];
    
    [customProfileCell.imgViewClient setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[self.selectedVet.review_details objectForKey:@"host"],[self.selectedVet.review_details objectForKey:@"image_url"]]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewVetProfile.image = image;
        else
            imgViewVetProfile.image = [UIImage imageNamed:@"DummyProfile"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            NSString *str = [self.selectedVet.review_details objectForKey:@"name"];
    customProfileCell.lblClientName.text = str.capitalizedString;
       
        }
    
    return customProfileCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
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
