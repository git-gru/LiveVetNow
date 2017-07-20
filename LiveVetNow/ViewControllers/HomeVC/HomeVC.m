//
//  HomeVC.m
//  LiveVetNow
//
//  Created by Apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "HomeVC.h"
#import "Constants.h"
#import "MFSideMenu.h"
#import "FindYourVetViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "UIImageView+Customization.h"
#import "UIView+Customization.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AddPetViewController.h"

@interface HomeVC ()
{
    IBOutlet UIView *viewEmergencyCall;
    
    IBOutlet UILabel *labelFindYourVet;
    IBOutlet UIView *viewAddPet;
    IBOutlet UIView *viewInviteyourVet;
    IBOutlet UIView *viewFindYourVet;
    IBOutlet UIImageView *imgViewProfile;
    IBOutlet UIImageView *imgViewDot;
}

@end

@implementation HomeVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imgViewProfile = [UIImageView roundImageViewWithBorderColourWithImageView:imgViewProfile withColor:[UIColor whiteColor]];
    

    
    
    imgViewDot = [UIImageView roundImageViewWithBorderColourWithImageView:imgViewDot withColor:[UIColor clearColor]];
    viewFindYourVet = [UIView addBorderToView:viewFindYourVet];
    viewInviteyourVet = [UIView addBorderToView:viewInviteyourVet];
    viewAddPet = [UIView addBorderToView:viewAddPet];
    viewEmergencyCall = [UIView addBorderToView:viewEmergencyCall];
    NSString *profilePicUrl;
//    if (kAppDelegate.isVet) {
//        profilePicUrl = model_manager.profileManager.owner.profilePicUrl;
//    }
//    else {
//         profilePicUrl = model_manager.profileManager.ownerVet.image_url;
//    }
//    [imgViewProfile setImageWithURL:[NSURL URLWithString:profilePicUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image)
//            imgViewProfile.image = image;
//        else
//            imgViewProfile.image = [UIImage imageNamed:@"DummyProfile"];
//    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    

    if (kAppDelegate.isVet) {
        profilePicUrl = model_manager.profileManager.ownerVet.image_url;
    }
    else {
        profilePicUrl = model_manager.profileManager.owner.profilePicUrl;
    }
    [imgViewProfile setImageWithURL:[NSURL URLWithString:profilePicUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
            imgViewProfile.image = image;
        else
            imgViewProfile.image = [UIImage imageNamed:@"DummyProfile"];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
    [imgViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.owner.profilePicUrl] placeholderImage:[UIImage imageNamed:@"DummyProfile" ] completed:nil];

}

- (IBAction)btnMenuAction:(id)sender {
    //[kAppDelegate logOut];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (IBAction)btnNewConsultationAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kFindYourVetStoryboard bundle:nil];
    FindYourVetViewController *findYourVetViewController = [storyboard instantiateViewControllerWithIdentifier:kFindYourVetStoryboardIdentifier];
    findYourVetViewController.showOnlineSegmentOnly = false;
    [self.navigationController pushViewController:findYourVetViewController animated:YES];
}

- (IBAction)bigButtonsAction:(UIButton*)sender {
    switch (sender.tag) {
        
        case 1:{
            
            [self goToVetListing];


        }
            break;
        case 2: {
            [self showPopToInviteVet];
        }
            break;
        case 3:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kFindYourVetStoryboard bundle:nil];
            FindYourVetViewController *findYourVetViewController = [storyboard instantiateViewControllerWithIdentifier:kFindYourVetStoryboardIdentifier];
            findYourVetViewController.type = @"emergency";

            [self.navigationController pushViewController:findYourVetViewController animated:YES];
      

        }
            break;
            
        case 4: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PetsListing" bundle:nil];
            AddPetViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"AddPetViewController"];
            [self.navigationController pushViewController:objPetListing animated:true];
        }
            break;
            
        default:
            break;
    }
}
- (IBAction)newConsultationAction:(id)sender {
    
    [self goToVetListing];
    
}
-(void)goToVetListing
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kFindYourVetStoryboard bundle:nil];
    FindYourVetViewController *findYourVetViewController = [storyboard instantiateViewControllerWithIdentifier:kFindYourVetStoryboardIdentifier];
    findYourVetViewController.type = @"";
    [self.navigationController pushViewController:findYourVetViewController animated:YES];
}

-(void)showPopToInviteVet {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"LIVE VET NOW" message: @"Please Enter Name and Email of the Vet you want to Invite." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        UITextField * passwordfiled = textfields[1];
        NSLog(@"%@:%@",namefield.text,passwordfiled.text);
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:passwordfiled.text,@"email",namefield.text,@"name", nil];
        [model_manager.vetManager inviteVet:dict withCompletionBlock:^(BOOL success,NSString *message)
         {
             if (success)
             {
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Doctor Invited successfully." preferredStyle:UIAlertControllerStyleAlert];

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
