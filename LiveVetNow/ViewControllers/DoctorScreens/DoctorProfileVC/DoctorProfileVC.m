//
//  DoctorProfileVC.m
//  LiveVetNow
//
//  Created by Apple on 30/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "DoctorProfileVC.h"
#import "DoctorUpgradeViewController.h"
#import "DoctorProfleEditViewController.h"
#import "MyPaymentsViewController.h"
#import "Constants.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "ViewController.h"

@interface DoctorProfileVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titles;
    
    IBOutlet UIButton *btnLocation;
    IBOutlet UIButton *btnSpeciality;
    IBOutlet UIImageView *image;
    IBOutlet UILabel *name;
    IBOutlet UILabel *overView;
    NSDictionary *dictSessionData;

}

@end

@implementation DoctorProfileVC

-(void)viewWillAppear:(BOOL)animated
{
    
    
    overView.text = model_manager.profileManager.ownerVet.overview;
    overView.hidden = true;
    
    name.text = model_manager.profileManager.ownerVet.name;
    [btnSpeciality setTitle:model_manager.profileManager.ownerVet.speciality_name forState:UIControlStateNormal];
    [btnLocation setTitle:model_manager.profileManager.ownerVet.state forState:UIControlStateNormal];

    
    [image sd_setImageWithURL:[NSURL URLWithString:model_manager.profileManager.ownerVet.image_url] placeholderImage: [UIImage imageNamed:@"DummyProfile"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    titles = [NSArray arrayWithObjects:@"",@"PROFILE SETTINGS",@"CHANGE PAYPAL ID",@"", nil];
   
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



#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        
        return  100;
    }
    else{
        
        return  60;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *customListingCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileCell"];
    UITableViewCell *firstCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"firstCell"];
    UILabel *overview = [firstCell.contentView viewWithTag:1];
    overview.text = model_manager.profileManager.ownerVet.overview;
    
    UITableViewCell *recomendedCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"recomendedCell"];
    
    UILabel *label = (UILabel*)[customListingCell.contentView viewWithTag:1];
    UIView *customSeparator = (UIView*)[customListingCell.contentView viewWithTag:2];
    
    if (indexPath.row == 0)
    {
        
        return firstCell;
 
    }
    
    if (indexPath.row == 3)
    {
        return recomendedCell;

        
    }

    else{
        if (indexPath.row == 2)
        {
            customSeparator.hidden = true;
        
        }
        else{
            
            customSeparator.hidden = false;

            
        }
   
        label.text = [titles objectAtIndex:indexPath.row];
    
       return customListingCell;
    
    
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (indexPath.row == 0)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
        
        MyPaymentsViewController *obj =[storyBoard instantiateViewControllerWithIdentifier:@"DoctorMyPayments"];
        
        [self.navigationController pushViewController:obj animated:true];
        
        
    }
     */
    
    if (indexPath.row == 1)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
        
        DoctorProfleEditViewController *obj =[storyBoard instantiateViewControllerWithIdentifier:@"ProfileEdit"];
      obj.editType = @"Doctor";
        
        [self.navigationController pushViewController:obj animated:true];
        
        
    }
    if (indexPath.row == 2)
    {
        [self showPopToInviteVet];
        
        
    }

    if (indexPath.row == 3)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
       
        DoctorUpgradeViewController *obj =[storyBoard instantiateViewControllerWithIdentifier:@"DoctorUpgrade"];

        
        [self.navigationController pushViewController:obj animated:true];
        
    
    }
    /*
    if (indexPath.row == 3)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"autoLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tabBarController.navigationController popViewControllerAnimated:true];
        
        
    }

    */
    
    
    
}
-(void)showPopToInviteVet {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"LIVE VET NOW" message: @"Please Enter your current PaypalID." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"PaypalID";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
       [alertController addAction:[UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        
           NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:namefield.text,@"paypal_id",model_manager.profileManager.ownerVet.vetId,@"doctor_id", nil];
        [model_manager.profileManager upgradeDoctorPaypalIDWithParams:dict handler:^(BOOL success , NSString *message)
         {
             if (success)
             {
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"PaypalID updated succesfully." preferredStyle:UIAlertControllerStyleAlert];
                 
                 [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                     
                     // Cancel button tappped.
                     [alert dismissViewControllerAnimated:true completion:nil];
                     
                     
                 }]];
                 [self presentViewController:alert animated:YES completion:nil];
                 
                 
             }
         }
         ];
        
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)btnBackAction:(id)sender {
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
