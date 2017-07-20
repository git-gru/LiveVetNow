//
//  SignUpVC.m
//  LiveVetNow
//
//  Created by Apple on 11/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "SignUpVC.h"
#import "UITextField+Customization.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@import SafariServices;

@interface SignUpVC ()<UITextFieldDelegate, SFSafariViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    IBOutlet UIView *viewPickerView;
    IBOutlet UITextField *textFieldName;
    NSString *signUpType;
    IBOutlet UITextField *textFieldConfirmPassword;
    IBOutlet UITextField *textFieldPassword;
    IBOutlet UITextField *textFieldEmail;
    IBOutlet UISegmentedControl *segmentedControl;
    NSString *selectedLocationId;
    NSArray *doctorLocationsArray;
    
    IBOutlet UIPickerView *pickerViewLocations;
}

@end

@implementation SignUpVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self customiseSegmentedControl];
    textFieldName = [UITextField addLayerToTextField:textFieldName];

    textFieldPassword = [UITextField addLayerToTextField:textFieldPassword];
    textFieldEmail = [UITextField addLayerToTextField:textFieldEmail];
    textFieldName = [UITextField addLayerToTextField:textFieldName];
    textFieldConfirmPassword = [UITextField addLayerToTextField:textFieldConfirmPassword];
    signUpType = @"user";
    selectedLocationId = @"";
    // fetch locations for doctor
    [self fetchLocations];
}

-(void)fetchLocations {
    [model_manager.login_Manager fetchLocationswithCompletionBlock:^(BOOL success,NSArray* locationsArray) {
         if (success) {
             doctorLocationsArray = [NSArray arrayWithArray:locationsArray];
             [pickerViewLocations reloadAllComponents];
         }
     }];
}

- (IBAction)btnBackAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}
- (IBAction)switchControlAction:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0)
    {
        
        signUpType = @"user";
    
    }
    else{
        
        signUpType = @"doctor";

    }
    
}


-(void)customiseSegmentedControl
{
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    
    segmentedControl.layer.cornerRadius = segmentedControl.frame.size.height/2;
    segmentedControl.layer.borderColor = [segmentedControl tintColor].CGColor;
    segmentedControl.layer.borderWidth = 1.0f;
    segmentedControl.layer.masksToBounds = YES;
    
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -150;
        self.view.frame = f;
    }];

}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
        [self.view layoutIfNeeded];

    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if (textField == textFieldName)
    {
        [textFieldEmail becomeFirstResponder];

        
    }
    if (textField == textFieldEmail)
    {
        
        [textFieldPassword becomeFirstResponder];

    }
    if (textField == textFieldPassword)
    {
        
        [textFieldConfirmPassword becomeFirstResponder];
    }
    else{
        
        [textField resignFirstResponder];
        
    }
    return true;
}

-(IBAction)termsPressed:(UIButton*)button{
    NSLog(@"terms Pressed");
    //[self openLink:@""];
}

-(IBAction)privacyPressed:(UIButton*)button{
    NSLog(@"privacy Pressed");
    //[self openLink:@""];
}

- (void)openLink:(NSString*)url {
   
    if (kAppDelegate.isInternetReachable) {
        if ([SFSafariViewController class] != nil) {
            // Use SFSafariViewController
            SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:url] entersReaderIfAvailable:NO];
            safariVC.delegate = self;
            [self presentViewController:safariVC animated:NO completion:nil];
        } else {
            // Open in Mobile Safari
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Opened url");
                }
            }];
        }
    }
    else
        [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
}


- (IBAction)btnSignUpAction:(id)sender {
    
   
    if (([textFieldName.text isEqualToString:@" "]) || (textFieldName.text.length == 0)) {
       
        [self showAlert:@"Please enter valid name"];
        
        return;
        
    }
    else if((textFieldName.text.length < 3)) {
        
        [self showAlert:@"Please enter a name atleast 3 characters long"];
        
        return;
    }
    
   
    if (([textFieldEmail.text isEqualToString:@" "]) || (textFieldEmail.text.length == 0)) {
        [self showAlert:@"Please enter your email"];
        
        return;
        
    }
    else if(![self validEmail:textFieldEmail.text]) {
        
        [self showAlert:@"Please enter valid email"];
        
        return;
    }
    else if (([textFieldPassword.text isEqualToString:@" "]) || (textFieldPassword.text.length == 0)) {
        [self showAlert:@"Please enter your password"];
        return;
    }
    else if (textFieldPassword.text.length < 6) {
        [self showAlert:@"Your password must be 6 characters long"];
        return;
    }
    
    else if (![textFieldPassword.text isEqualToString:textFieldConfirmPassword.text]) {
        [self showAlert:@"Password and Confirm Password do not match"];
        return;
    }
    else if ([selectedLocationId isEqualToString:@""] && [signUpType isEqualToString:@"doctor"])
    {
        
        [self showAlert:@"Please select your location from drop down"];

        
    }
    else
    {

        [self signUpUser];
    }
    
    
}

- (void)signUpUser
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:textFieldEmail.text,@"email",textFieldName.text,@"name",textFieldPassword.text,@"password",signUpType,@"user_type",selectedLocationId,@"location_id",@"1",@"speciality_id", nil];
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.login_Manager registerUser:dict withCompletionBlock:^(BOOL success,NSString *message) {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         [self showAlert:message];
        [self.navigationController popViewControllerAnimated:true];
         
     }];
    
    
}


-(void)showAlert:(NSString*)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LiveVetNow", nil)  message:NSLocalizedString(message, nil)  preferredStyle:UIAlertControllerStyleAlert];
   
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([message isEqualToString:@"Please select your location from drop down"])
            
        {
            
            viewPickerView.hidden = false;
        
        }
        
    }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Custom Methods
//Check if valid email address format
-(BOOL)validEmail:(NSString*)emailString {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView

{
    return 1;
    
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return  [[doctorLocationsArray objectAtIndex:row] objectForKey:@"state"];

}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return  doctorLocationsArray.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    selectedLocationId = [NSString stringWithFormat:@"%@",[[doctorLocationsArray objectAtIndex:row] objectForKey:@"id"]] ;
    
    
}
- (IBAction)btnDonePickerAction:(id)sender {
    
    
    [viewPickerView setHidden:true];
    
    
}


#pragma mark - SFSafariViewController delegate methods
-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Load finished
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
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
