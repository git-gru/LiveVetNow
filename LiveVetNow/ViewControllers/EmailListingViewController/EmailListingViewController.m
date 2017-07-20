//
//  EmailListingViewController.m
//  LiveVetNow
//
//  Created by apple on 06/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "EmailListingViewController.h"
#import "EmailDetailViewController.h"
#import "Constants.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MBProgressHUD.h"
#import "EmailListingTableViewCell.h"
#import "Email.h"
#import "UIImageView+Customization.h"

@interface EmailListingViewController () {
    __weak IBOutlet UITableView *tableViewEmailList;
    __weak IBOutlet UILabel *lblMessageHeader;
    NSDictionary *dictSessionData;
}

@end

@implementation EmailListingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self getEmailList];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadViews];
    tableViewEmailList.estimatedRowHeight = 80;
    tableViewEmailList.rowHeight = UITableViewAutomaticDimension;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"callStarted" object:nil];

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


-(void)loadViews {
    tableViewEmailList.hidden = YES;
}

-(void)getEmailList {
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.emailManager getEmails:nil withCompletionBlock:^(BOOL success, NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            tableViewEmailList.hidden = NO;
            [tableViewEmailList reloadData];
        }
        else{
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnReplyToEmailAction:(id)sender {
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewEmailList];
    NSIndexPath *indexPath = [tableViewEmailList indexPathForRowAtPoint:rootViewPoint];
    Email *selectedEmail = [model_manager.emailManager.arrayEmails objectAtIndex: indexPath.row];
    if (selectedEmail != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
        EmailDetailViewController *objEmailDetail = [storyboard instantiateViewControllerWithIdentifier:@"EmailDetailVC"];
        objEmailDetail.receiverId = selectedEmail.msg_from;
        objEmailDetail.receiverName = selectedEmail.msg_from_name;
        [self.navigationController pushViewController:objEmailDetail animated:true];
    }
}

#pragma mark - table view delegates and datasources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model_manager.emailManager.arrayEmails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmailListingTableViewCell *emailListingCell = (EmailListingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kEmailListingTableViewCellIdentifier];
    emailListingCell.imgViewSender = [UIImageView roundImageViewWithBorderColourWithImageView:emailListingCell.imgViewSender withColor:[UIColor lightGrayColor]];
    
    [emailListingCell.btnReply addTarget:self action:@selector(btnReplyToEmailAction:) forControlEvents:UIControlEventTouchUpInside];
    Email *currentEmail = [model_manager.emailManager.arrayEmails objectAtIndex:indexPath.row];
    
    if (!kAppDelegate.isVet)
    {
    if ([currentEmail.msg_from_name isEqualToString:model_manager.profileManager.owner.name]) {
        emailListingCell.lblSenderName.text = currentEmail.msg_to_name;
        emailListingCell.lblEmail .text = currentEmail.message;
        [emailListingCell.btnReply setTitle:@"Sent" forState:UIControlStateNormal];
       // emailListingCell.lblDate
        //emailListingCell.lblEmail .text = @"sadjhgashkdfsdahjhdsfhsdafhdfsghfsdhgdsafghjadfshfsahgasfhgasdfhgdsafhgdsafhdgsafhgdsafhgdfshgdsafhdfsahfdahfdashfdsahdsafhdsfhdsfhfhsdaghdasfdhafghfgadhgdfshgdsfahgfdsahgfahgafsdhgfadsfhdafhdshafaghdsdgahhdfagshjgfadshgfadfhgadfhgdafhjfgdhgfadhjgadfshgdahgasdfhjdafahdj";
        emailListingCell.lblDate.text = currentEmail.updated_at;
        [emailListingCell.imgViewSender setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentEmail.to_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                emailListingCell.imgViewSender.image = image;
            else
                emailListingCell.imgViewSender.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      
    }
    else{
        
        emailListingCell.lblSenderName.text = currentEmail.msg_from_name;
        emailListingCell.lblEmail .text = currentEmail.message;
        [emailListingCell.btnReply setTitle:@"Received" forState:UIControlStateNormal];

        //emailListingCell.lblEmail .text = @"sadjhgashkdfsdahjhdsfhsdafhdfsghfsdhgdsafghjadfshfsahgasfhgasdfhgdsafhgdsafhdgsafhgdsafhgdfshgdsafhdfsahfdahfdashfdsahdsafhdsfhdsfhfhsdaghdasfdhafghfgadhgdfshgdsfahgfdsahgfahgafsdhgfadsfhdafhdshafaghdsdgahhdfagshjgfadshgfadfhgadfhgdafhjfgdhgfadhjgadfshgdahgasdfhjdafahdj";
        emailListingCell.lblDate.text = currentEmail.updated_at;
        [emailListingCell.imgViewSender setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentEmail.from_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                emailListingCell.imgViewSender.image = image;
            else
                emailListingCell.imgViewSender.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
    }
    }
    else{
        
        if ([currentEmail.msg_from_name isEqualToString:model_manager.profileManager.ownerVet.name]) {
            emailListingCell.lblSenderName.text = currentEmail.msg_to_name;
            emailListingCell.lblEmail .text = currentEmail.message;
            [emailListingCell.btnReply setTitle:@"Sent" forState:UIControlStateNormal];

            //emailListingCell.lblEmail .text = @"sadjhgashkdfsdahjhdsfhsdafhdfsghfsdhgdsafghjadfshfsahgasfhgasdfhgdsafhgdsafhdgsafhgdsafhgdfshgdsafhdfsahfdahfdashfdsahdsafhdsfhdsfhfhsdaghdasfdhafghfgadhgdfshgdsfahgfdsahgfahgafsdhgfadsfhdafhdshafaghdsdgahhdfagshjgfadshgfadfhgadfhgdafhjfgdhgfadhjgadfshgdahgasdfhjdafahdj";
            emailListingCell.lblDate.text = currentEmail.updated_at;
            [emailListingCell.imgViewSender setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentEmail.to_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                    emailListingCell.imgViewSender.image = image;
                else
                    emailListingCell.imgViewSender.image = [UIImage imageNamed:@"DummyProfile"];
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
        }
        else{
            
            emailListingCell.lblSenderName.text = currentEmail.msg_from_name;
            emailListingCell.lblEmail .text = currentEmail.message;
            [emailListingCell.btnReply setTitle:@"Received" forState:UIControlStateNormal];

            //emailListingCell.lblEmail .text = @"sadjhgashkdfsdahjhdsfhsdafhdfsghfsdhgdsafghjadfshfsahgasfhgasdfhgdsafhgdsafhdgsafhgdsafhgdfshgdsafhdfsahfdahfdashfdsahdsafhdsfhdsfhfhsdaghdasfdhafghfgadhgdfshgdsfahgfdsahgfahgafsdhgfadsfhdafhdshafaghdsdgahhdfagshjgfadshgfadfhgadfhgdafhjfgdhgfadhjgadfshgdahgasdfhjdafahdj";
            emailListingCell.lblDate.text = currentEmail.updated_at;
            [emailListingCell.imgViewSender setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentEmail.from_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                    emailListingCell.imgViewSender.image = image;
                else
                    emailListingCell.imgViewSender.image = [UIImage imageNamed:@"DummyProfile"];
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
        }

        
    }
    return emailListingCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Email *selectedEmail = [model_manager.emailManager.arrayEmails objectAtIndex: indexPath.row];
    EmailListingTableViewCell *emailListingCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (![emailListingCell.btnReply.currentTitle isEqualToString:@"Sent"])
    {
           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Email" bundle:nil];
        EmailDetailViewController *objEmailDetail = [storyboard instantiateViewControllerWithIdentifier:@"EmailDetailVC"];
        objEmailDetail.receiverId = selectedEmail.msg_from;
        objEmailDetail.receiverName = selectedEmail.msg_from_name;
        [self.navigationController pushViewController:objEmailDetail animated:true];
    }
    
    
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
