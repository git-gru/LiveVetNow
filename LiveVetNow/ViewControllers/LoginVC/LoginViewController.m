//
//  LoginViewController.m
//  LiveVetNow
//
//  Created by apple on 12/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "LoginViewController.h"
#import "LeftMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "HomeVC.h"
#import "Constants.h"
#import "UITextField+Customization.h"
#import "SignUpVC.h"
#import "DoctorHomeViewController.h"
#import "DoctorProfileVC.h"
#import "ViewController.h"
#import "MBProgressHUD.h"
#import "ViewController.h"
#import "UIImage+Customization.h"

@interface LoginViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;



@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    _txtEmail = [UITextField addLayerToTextField:_txtEmail];
    _txtPassword = [UITextField addLayerToTextField:_txtPassword];
    _btnSignup.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnSignup.layer.borderWidth = 1.0f;
    
    //call if autologin
    [self autoLogin];

    _txtEmail.text = @"abc@abc.com";
    _txtPassword.text = @"aaaaaaaa";
}

#pragma mark Custom Button Methods

-(IBAction)loginPressed:(id)sender {
    
    //kAppDelegate.isVet = true;
   // [self callSlideMenuAnimated:true];

    [_txtEmail resignFirstResponder];
    [_txtPassword resignFirstResponder];
    if (([_txtEmail.text isEqualToString:@" "]) || (_txtEmail.text.length == 0)) {
        [self showAlert:@"Please enter your email"];
        return;
    }
    else if(![self validEmail:_txtEmail.text]) {
        
        [self showAlert:@"Please enter valid email"];
        
        return;
    }
    else if (([_txtPassword.text isEqualToString:@" "]) || (_txtPassword.text.length == 0)) {
        [self showAlert:@"Please enter your password"];
        return;
    }
    else if (_txtPassword.text.length < 6) {
        [self showAlert:@"Your password must be 6 characters long"];
        return;
    }
    // hit the login service
    else {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_txtEmail.text,@"email",_txtPassword.text,@"password",nil];
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
        [model_manager.login_Manager login:dict withCompletionBlock:^(BOOL success,NSString *message) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                [self proccedToHome:true];
            }
            else{
                [self showAlert:message];
            }
        }];
    }
}

-(void)autoLogin {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"]) {
        [model_manager.login_Manager setLoginData:[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"] withCompletionBlock:^(BOOL complete) {
            if (complete) {
                [self proccedToHome:false];
            }
        }];
    }
}

-(void)proccedToHome:(BOOL)animated{
    if (kAppDelegate.isVet) {
        [model_manager.chatVendor initChatClient:model_manager.profileManager.ownerVet.vetId broadcast_id:model_manager.profileManager.ownerVet.broadcasting_id];
        [model_manager.chatVendor enablePushNotification:model_manager.profileManager.ownerVet.vetId];
        [self callSlideMenuAnimated:animated];
    }
    else {
        [self fetchPets];
        [model_manager.chatVendor initChatClient:model_manager.profileManager.owner.userID broadcast_id:@""];
        [model_manager.chatVendor enablePushNotification:model_manager.profileManager.owner.userID];
        [self callSlideMenuAnimated:animated];
    }
}

-(void)fetchPets {
    [model_manager.petManager getPets:nil withCompletionBlock:^(BOOL success,NSString* message) {
        if (success) {
            
        }
    }];
    /*
    [model_manager.emailManager getEmails:nil withCompletionBlock:^(BOOL success, NSString *message) {
        if (success) {
            
        }
    }];
     */
}



-(void)moveToDoctorScreen:(BOOL)animated {
    
    
    UIStoryboard *storyTabBar = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
    
    UITabBarController *tabbar = [storyTabBar instantiateInitialViewController];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }
                                             forState:UIControlStateNormal];
    
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageFromColor:[UIColor blueColor] forSize:CGSizeMake(tabbar.tabBar.frame.size.width/2, 50) withCornerRadius:0]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                             forState:UIControlStateSelected];
    
    [self.navigationController pushViewController:tabbar animated:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}


-(void)showAlert:(NSString*)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LiveVetNow", nil)  message:NSLocalizedString(message, nil)  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(IBAction)signupPressed:(id)sender {
    UIStoryboard *signupStoryboard = [UIStoryboard storyboardWithName:@"SignUp" bundle:nil];
    SignUpVC *signUpObj = [signupStoryboard instantiateViewControllerWithIdentifier:@"signUp"];
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController pushViewController:signUpObj animated:true];
}


#pragma mark slidemenu methods

- (id)mainController {
    if (!kAppDelegate.isVet)
    {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    HomeVC *homeObj = [storyboard instantiateViewControllerWithIdentifier:@"home"];
        return homeObj;

    }
    else{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
        DoctorHomeViewController *homeObj = [storyboard instantiateViewControllerWithIdentifier:@"DoctorNewHomeViewController"];
        return homeObj;
    }
    
}


- (UINavigationController *)navigationControllers {
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[self mainController]];
    nav.navigationBarHidden = true;
    return nav;
}

-(void)callSlideMenuAnimated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LeftMenu" bundle:nil];
    
    LeftMenuViewController *leftMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self navigationControllers]
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    container.panMode = MFSideMenuPanModeNone;
    //  [self.navigationController pushViewController:[self mainController] animated:true];
    
    //slideContainer=container;
    [self.navigationController pushViewController:container animated:animated];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if (textField == _txtEmail)
    {
        [_txtPassword becomeFirstResponder];
        
        
    }
    if (textField == _txtPassword)
    {
        
        [textField resignFirstResponder];
        
    }
    
    return true;
}

#pragma mark Custom Methods
//Check if valid email address format
-(BOOL)validEmail:(NSString*)emailString {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

-(void)setupView {
    [_btnSignup.layer setBorderColor:[[UIColor whiteColor] CGColor]];
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
