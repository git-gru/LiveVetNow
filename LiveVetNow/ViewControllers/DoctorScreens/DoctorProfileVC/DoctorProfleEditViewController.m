//
//  DoctorProfleEditViewController.m
//  LiveVetNow
//
//  Created by Apple on 04/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "DoctorProfleEditViewController.h"
#import "Constants.h"
#import "Base64.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "ViewController.h"
@interface DoctorProfleEditViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    IBOutlet UILabel *lblAboutMe;
    IBOutlet UIImageView *imgViewProfile;
    IBOutlet UITableView *tblViewProfileEdit;
    IBOutlet UITextField *txtFieldName;
    IBOutlet UITextView *txtViewAboutMe;
    NSArray *titles;
    NSArray *specialitiesList;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UIView *viewPickerView;
    NSString *selectedSpecialityID;
    NSString *selectedLocationId;
    UIImage *chosenImage;
    NSString *selectedSpecialityName;
    NSString *selectedLocationName;
    NSString *refreshType;
    NSArray *doctorLocationsArray;
    NSDictionary *dictSessionData;

    IBOutlet UIView *upperView;
    IBOutlet NSLayoutConstraint *upperViewHeightConstraint;

}

@end

@implementation DoctorProfleEditViewController
@synthesize editType;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtViewAboutMe.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"callStarted" object:nil];

    if ([editType isEqualToString:@"Doctor"])
    {
    titles = [NSArray arrayWithObjects:@"PASSWORD",@"SPECIALITY",@"LOCATION", nil];
        txtViewAboutMe.text = model_manager.profileManager.ownerVet.overview;
        txtFieldName.text = model_manager.profileManager.ownerVet.name;
        [imgViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.ownerVet.image_url] placeholderImage:[UIImage imageNamed:@"DummyProfile"] completed:nil];
        
        selectedSpecialityName = model_manager.profileManager.ownerVet.speciality_name;
        selectedLocationName  = model_manager.profileManager.ownerVet.state;
        [model_manager.profileManager getDoctorSpecialities:^(BOOL success , NSArray *specialities )
         {
             
             if (success)
             {
                 
                 specialitiesList = [NSArray arrayWithArray:specialities];
                 for (int i = 0 ; i< specialitiesList.count ; i++)
                     
                 {
                     if  ([[[specialitiesList objectAtIndex:i] objectForKey:@"speciality_name"] isEqualToString:selectedSpecialityName])
                     {
                         
                         selectedSpecialityID = [[specialitiesList objectAtIndex:i] objectForKey:@"speciality_id"];
                     }
                     
                     
                 }
                 
             }
             
         }];
        [self fetchLocations];


    }
    
    else if ([editType isEqualToString:@"Pet"])
    {
        titles = [NSArray arrayWithObjects:@"AGE(IN MONTHS)", nil];
       // txtViewAboutMe.text = _currentPet.;
        txtFieldName.text = _currentPet.pet_name;
        lblAboutMe.text = @"ABOUT PET";
      //  txtViewAboutMe.text = _currentPet.pe;
        [imgViewProfile setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_currentPet.pet_host,_currentPet.pet_image_url]]placeholderImage:[UIImage imageNamed:@"DummyProfile"] completed:nil];


        
    }
    else{
        
        upperViewHeightConstraint.constant = 200;
        lblAboutMe.hidden = true;
        titles = [NSArray arrayWithObjects:@"PASSWORD", nil];
        txtViewAboutMe.hidden = true;
        txtFieldName.text = model_manager.profileManager.owner.name;
        [imgViewProfile setImageWithURL:[NSURL URLWithString:model_manager.profileManager.owner.profilePicUrl] placeholderImage:[UIImage imageNamed:@"DummyProfile"] completed:nil];

    }
    

    
    
  
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



-(void)fetchLocations {
    [model_manager.login_Manager fetchLocationswithCompletionBlock:^(BOOL success,NSArray* locationsArray) {
        if (success) {
            
            doctorLocationsArray = [NSArray arrayWithArray:locationsArray];
            for (int i = 0 ; i< doctorLocationsArray.count ; i++)
                
            {
                if  ([[[doctorLocationsArray objectAtIndex:i] objectForKey:@"state"] isEqualToString:selectedLocationName])
                {
                    
                    selectedLocationId = [[doctorLocationsArray objectAtIndex:i] objectForKey:@"id"];
                }
                
                
            }
            
        }
    }];
}
- (IBAction)btnBackAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([editType isEqualToString:@"Doctor"])
    {
    return 3;
    
    }
    else if ([editType isEqualToString:@"Pet"])
    {
        
        return 1;
    }
    else{
        
        return  1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *customListingCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileEditCell"];
    
    
    UILabel *label = (UILabel*)[customListingCell.contentView viewWithTag:1];
    UITextField *passTextField = (UITextField*)[customListingCell.contentView viewWithTag:2];

    UIButton *select = (UIButton*)[customListingCell.contentView viewWithTag:333];

    
    if ([editType isEqualToString:@"Doctor"])
    {

        if (indexPath.row == 0)
        {
            passTextField.hidden = false;
            select.hidden = true;
            
        }
    
    
        else{
            
            passTextField.hidden = true;
            
            select.hidden = false;
            if (indexPath.row == 0 )
            {
                if (selectedSpecialityName)
                {
                [select setTitle:selectedSpecialityName forState:UIControlStateNormal];
                }
            }
            else{
                
                if (selectedLocationName)
                {
                [select setTitle:selectedLocationName forState:UIControlStateNormal];
                }

            }

       }
    }
    else if ([editType isEqualToString:@"Pet"])
    {
        
        passTextField.hidden = false;
        passTextField.secureTextEntry = false;
        select.hidden = true;
        passTextField.userInteractionEnabled = true;
        passTextField.text = _currentPet.pet_age;
        
    }
    else{
        
        passTextField.hidden = false;

        select.hidden = true;

        
    }
    
        label.text = [titles objectAtIndex:indexPath.row];
        
        return customListingCell;
        
        
    }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;\
{
    if (indexPath.row == 0)
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"LiveVetNow" message:@"Please enter your current and new password to change password" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Current password";
            textField.secureTextEntry = YES;
        }];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"New password";
            textField.secureTextEntry = YES;
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Current password %@", [[alertController textFields][0] text]);
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[alertController textFields][0] text],@"old_password" ,[[alertController textFields][1] text],@"new_password",nil];
            
            [model_manager.profileManager changePasswordWithParams:dict handler:^(BOOL success,NSString* message){
                
                if (success)
                {
                    // show alert
                    
                }
            
            
            }];
            
            
            //compare the current password and do action here
            
        }];
        [alertController addAction:confirmAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Canelled");
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}

- (IBAction)btnEditPictureAction:(id)sender {
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"Select Option" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [actionSheet dismissViewControllerAnimated:true completion:nil];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Open Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCameraWithSourceType:UIImagePickerControllerSourceTypeCamera];
        [actionSheet dismissViewControllerAnimated:true completion:nil];
        
        // Distructive button tapped.
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Open Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self openCameraWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        // OK button tapped.
        
        [actionSheet dismissViewControllerAnimated:true completion:nil];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)openCameraWithSourceType:(UIImagePickerControllerSourceType)source
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    
    if([UIImagePickerController isSourceTypeAvailable:source])
    {
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = source;
        
    }
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    chosenImage = image;
    imgViewProfile.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];

}



- (IBAction)btnSelectAction:(UIButton *)sender {
    
    UITableViewCell *customListingCell  =(UITableViewCell*) sender.superview.superview;
    
    NSIndexPath *index = [tblViewProfileEdit indexPathForCell:customListingCell];
    
    if (index.row == 0)
    {
        // speciality refresh
        refreshType = @"specialities";
    }
    else{
        
        refreshType = @"location";

    }
    [pickerView reloadAllComponents];
    viewPickerView.hidden = false;
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return textView.text.length + (text.length - range.length) <= 100;
    
    
}
- (IBAction)btnDoneAction:(id)sender {
    
    
    [tblViewProfileEdit reloadData];
    viewPickerView.hidden = true;

    
}

- (IBAction)btnSaveAction:(id)sender {
    
   
    if ([editType isEqualToString:@"Doctor"])
    {
    NSDictionary *profileDict = [NSDictionary dictionaryWithObjectsAndKeys:txtFieldName.text, @"name",txtViewAboutMe.text,@"about_me",selectedSpecialityID,@"speciality_id",selectedLocationId,@"location_id",nil];
    
    [model_manager.profileManager editDetails:profileDict withCompletionBlock:^(BOOL success,NSString* message)
     {
         if (success)
         {
             model_manager.profileManager.ownerVet.overview = txtViewAboutMe.text;
             model_manager.profileManager.ownerVet.name = txtFieldName.text;
             model_manager.profileManager.ownerVet.speciality_name = selectedSpecialityName;
             model_manager.profileManager.ownerVet.state = selectedLocationName;

             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Details Updated Sucesfully" preferredStyle:UIAlertControllerStyleAlert];
             
             [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                 
                 // Cancel button tappped.
                 [alert dismissViewControllerAnimated:true completion:nil];
                 
             }]];
             [self presentViewController:alert animated:true completion:nil];

             
         }
         else{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
             
             [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                 
                 // Cancel button tappped.
                 [alert dismissViewControllerAnimated:true completion:nil];
                 
             }]];
             [self presentViewController:alert animated:true completion:nil];
             
         }
     
    
     
     }];
    }
    
    else if ([editType isEqualToString:@"Pet"])
    {
        NSDictionary *profileDict = [NSDictionary dictionaryWithObjectsAndKeys:txtFieldName.text,@"name",txtViewAboutMe.text,@"about_me",_currentPet.pet_id,@"pet_id",@"yes",@"is_pet",nil];
        
        [model_manager.profileManager editDetails:profileDict withCompletionBlock:^(BOOL success,NSString* message)
         {
             if (success)
             {
                 _currentPet.pet_name = txtFieldName.text;
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Details Updated Sucesfully" preferredStyle:UIAlertControllerStyleAlert];
                 
                 [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                     
                     // Cancel button tappped.
                     [alert dismissViewControllerAnimated:true completion:nil];
                     
                 }]];
                 [self presentViewController:alert animated:true completion:nil];
                 
                 
             }
             else{
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                 
                 [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                     
                     // Cancel button tappped.
                     [alert dismissViewControllerAnimated:true completion:nil];
                     
                 }]];
                 [self presentViewController:alert animated:true completion:nil];
                 
             }
             
             
             
         }];

        
    }
    else{
        
        NSDictionary *profileDict = [NSDictionary dictionaryWithObjectsAndKeys:txtFieldName.text, @"name",@"khj",@"about_me",nil];
        
        [model_manager.profileManager editDetails:profileDict withCompletionBlock:^(BOOL success,NSString* message)
         {
             if (success)
             {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Details Updated Sucesfully" preferredStyle:UIAlertControllerStyleAlert];
                 if ([editType isEqualToString:@"Doctor"])
                 {
                 model_manager.profileManager.ownerVet.name = txtFieldName.text;
                 }
                 else
                 {
                     model_manager.profileManager.owner.name = txtFieldName.text;

                 }
                 
                 [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                     
                     // Cancel button tappped.
                     [alert dismissViewControllerAnimated:true completion:nil];
                     
                 }]];
                 [self presentViewController:alert animated:true completion:nil];
                 
                 
             }
             else{
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                 
                 [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                     
                     // Cancel button tappped.
                     [alert dismissViewControllerAnimated:true completion:nil];
                     
                 }]];
                 [self presentViewController:alert animated:true completion:nil];
                 
             }
             
             
             
         }];

        
    }
    
    if (chosenImage != nil)
    {
        if (_currentPet !=nil)
        {
            [self uploadPetImage:chosenImage withPetId:_currentPet.pet_id];

        }
        else{
            
            [self uploadPetImage:chosenImage withPetId:nil];

        }
        
        
    }
    
    
}

-(void)uploadPetImage:(UIImage*)image withPetId:(NSString*)petId {
   /*
    [model_manager.petManager getPets:nil withCompletionBlock:^(BOOL success,NSString* message) {
        if (success) {
            
        }
    }];
    */
    NSString *imageBase64 = [Base64 encode:UIImageJPEGRepresentation(image, 0.1f)];
    NSString* encodedImageString = [imageBase64 stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    NSDictionary *profileDict = [NSDictionary dictionaryWithObjectsAndKeys:encodedImageString,@"image",nil];
    
    if (![petId isEqualToString:@""])
    {
        profileDict = [NSDictionary dictionaryWithObjectsAndKeys:encodedImageString,@"image",petId,@"vet_detail_id",nil];

    
    }

    [model_manager.petManager uploadPetImage:profileDict withCompletionBlock:^(BOOL success , NSString *message) {
        if (success) {
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView

{
    return 1;
    
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if ([refreshType isEqualToString:@"specialities"])
    {
    return  [[specialitiesList objectAtIndex:row] objectForKey:@"speciality_name"];
   
    }
    else{
        
        return  [[doctorLocationsArray objectAtIndex:row] objectForKey:@"state"];

        
    }
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([refreshType isEqualToString:@"specialities"])
    {
    return  specialitiesList.count;
    }
    else{
        
        return  doctorLocationsArray.count;

    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([refreshType isEqualToString:@"specialities"])
    {
    selectedSpecialityID = [NSString stringWithFormat:@"%@",[[specialitiesList objectAtIndex:row] objectForKey:@"speciality_id"]] ;
        selectedSpecialityName = [NSString stringWithFormat:@"%@",[[specialitiesList objectAtIndex:row] objectForKey:@"speciality_name"]];
    }
    else
    {
        
        selectedLocationId = [NSString stringWithFormat:@"%@",[[doctorLocationsArray objectAtIndex:row] objectForKey:@"id"]] ;
        selectedLocationName =  [[doctorLocationsArray objectAtIndex:row] objectForKey:@"state"];

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
