//
//  EmailDetailViewController.m
//  LiveVetNow
//
//  Created by apple on 06/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "EmailDetailViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface EmailDetailViewController () <UITextViewDelegate>{
    
    __weak IBOutlet UILabel *lblRecieverName;
    __weak IBOutlet UITextView *txtViewMessage;
}

@end

@implementation EmailDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadViews];
    txtViewMessage.delegate = self;
    txtViewMessage.text = @"Please enter a message";
    txtViewMessage.textColor = [UIColor lightGrayColor]; //optional
}

-(void)loadViews {
    lblRecieverName.text = [NSString stringWithFormat:@"To : %@",self.receiverName];
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

- (IBAction)btnSendAction:(id)sender {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.receiverId,@"msg_to",txtViewMessage.text,@"message",nil];
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.emailManager sendEmail:params withCompletionBlock:^(BOOL success,NSString* appointmentID) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            [model_manager.notificationManager notifiyEmail:self.receiverId];
            [self showAlert:@"Message Sent Successfully."];
        }
        else {
            [self presentViewController:[kAppDelegate showAlert:appointmentID] animated:YES completion:nil];
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


- (void)textViewDidChangeSelection:(UITextView *)textView {
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Please enter a message"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Please enter a message";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 200;
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
