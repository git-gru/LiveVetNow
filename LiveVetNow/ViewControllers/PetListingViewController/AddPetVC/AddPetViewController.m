//
//  AddPetViewController.m
//  LiveVetNow
//
//  Created by Apple on 31/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "AddPetViewController.h"
#import "UIView+Customization.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "Base64.h"
@interface AddPetViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIView *viewSelectPhto;
    
    IBOutlet UIButton *btnSelectPhto;
    IBOutlet UITableView *tableViewAddPet;
    IBOutlet NSLayoutConstraint *tblViewAddPetBottomConstraint;
    NSArray *petsTypes;
    NSString *selectedPetTypeId;
    NSString *selectedPetSex;
    NSString *selectedPetName;
    NSString *selectedPetAge;
    UIImage *chosenImage;
    
}

@end

@implementation AddPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [model_manager.petManager getPetTypeListWithCompletionBlock:^(BOOL success , NSArray *petsTypesArray)
     
     {
         
         petsTypes = [NSArray arrayWithArray:petsTypesArray];
         
         
     }
     ];
}

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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if (indexPath.row == 4)
    {
        return 150;
        
    }
    else{
        return 70;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    return  5;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *petTypeCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"petTypeCell"];
    UITableViewCell *addPetNameCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"petNameCell"];
    UITableViewCell *aboutPetCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"aboutPetCell"];
    
    UILabel *titleLabel = (UILabel*)[addPetNameCell.contentView viewWithTag:1];
    
    UILabel *titleLabelType = (UILabel*)[petTypeCell.contentView viewWithTag:2];
    
    UIButton *buttonSelection = (UIButton*)[petTypeCell.contentView viewWithTag:3];
    
    UITextField *name = (UITextField*)[addPetNameCell.contentView viewWithTag:4];
    
    UITextView *about = (UITextView*)[aboutPetCell.contentView viewWithTag:5];
    // Add shadow
    [about.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [about.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [about.layer setBorderWidth: 1.0];
    [about.layer setCornerRadius:12.0f];
    [about.layer setMasksToBounds:NO];
    about.layer.shouldRasterize = YES;
    [about.layer setShadowRadius:2.0f];
    about.layer.shadowColor = [[UIColor blackColor] CGColor];
    about.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    about.layer.shadowOpacity = 1.0f;
    about.layer.shadowRadius = 1.0f;
    
    
    if ((indexPath.row == 0) || (indexPath.row == 3))
    {
        if (indexPath.row == 0)
        {
            
            titleLabel.text = @"NAME";
            
            [name setPlaceholder:@"NAME"];
        }
        else{
            
            titleLabel.text = @"AGE(IN MONTHS)";
            [name setPlaceholder:@"AGE"];
            
        }
        
        return addPetNameCell;
        
    }
    else if ((indexPath.row == 1) || (indexPath.row == 2))
    {
        
        if (indexPath.row == 1)
        {
            titleLabelType.text = @"PET TYPE";
            [buttonSelection setTitle:@"SELECT" forState:UIControlStateNormal];
            buttonSelection.tag = indexPath.row;
        }
        else{
            
            [buttonSelection setTitle:@"SELECT" forState:UIControlStateNormal];
            titleLabelType.text = @"GENDER";
            buttonSelection.tag = indexPath.row;
            
        }
        
        return petTypeCell;
    }
    
    else
    {
        
        
        return aboutPetCell;
        
    }
    
}

- (IBAction)btnSelectOption:(UIButton *)sender {
    
    if (sender.tag == 1)
    {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"Select Pet Type" preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        for (NSDictionary*dict in petsTypes) {
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:[dict objectForKey:@"veterinary_name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                for (NSDictionary*dict in petsTypes)
                {
                    if ([[dict objectForKey:@"veterinary_name"] isEqualToString:action.title])
                    {
                        selectedPetTypeId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                        [sender setTitle:action.title.uppercaseString forState:UIControlStateNormal];
                        
                    }
                    
                }
                
                // Cancel button tappped.
                [actionSheet dismissViewControllerAnimated:true completion:nil];
                
            }]];
        }
        
        
        [self presentViewController:actionSheet animated:true completion:nil];
        
    }
    else{
        
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"Select Pet Type" preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"MALE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            selectedPetSex = action.title.lowercaseString;
            [sender setTitle:action.title forState:UIControlStateNormal];
            // Cancel button tappped.
            [actionSheet dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"FEMALE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            selectedPetSex = action.title.lowercaseString;
            [sender setTitle:action.title forState:UIControlStateNormal];
            
            
            // Cancel button tappped.
            [actionSheet dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        
        [self presentViewController:actionSheet animated:true completion:nil];
        
        
    }
    
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.placeholder isEqualToString:@"NAME"])
    {
        
        selectedPetName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    else{
        
        selectedPetAge = [textField.text stringByReplacingCharactersInRange:range withString:string];
        ;
        
        
    }
    
    return  true;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField

{
    [textField resignFirstResponder];
    
    return  true;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return textView.text.length + (text.length - range.length) <= 100;
    
    
}

- (IBAction)btnSelectPhotoAction:(id)sender {
    
    
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
    [btnSelectPhto setImage:chosenImage forState:UIControlStateNormal];
    [btnSelectPhto setContentMode:UIViewContentModeScaleToFill];
    viewSelectPhto.hidden = true;
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadPetImage:(UIImage*)image withPetId:(NSString*)petId {
    [model_manager.petManager getPets:nil withCompletionBlock:^(BOOL success,NSString* message) {
        if (success) {
            
        }
    }];
    NSString *imageBase64 = [Base64 encode:UIImageJPEGRepresentation(image, 0.1f)];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:imageBase64,@"image",petId,@"vet_detail_id",nil];
    [model_manager.petManager uploadPetImage:params withCompletionBlock:^(BOOL success , NSString *message) {
        if (success) {
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    tblViewAddPetBottomConstraint.constant = kbSize.height; //200 may be a bit off, should be height of keyboard
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    tblViewAddPetBottomConstraint.constant = 0; //200 may be a bit off, should be height of keyboard
    
}

- (IBAction)btnBackAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}
- (IBAction)btnDoneAction:(id)sender {
    
    if (!selectedPetAge || !selectedPetName || !selectedPetSex || !selectedPetAge)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please fill all the pet details" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [alert dismissViewControllerAnimated:true completion:nil];
            
        }]];
        
        [self presentViewController:alert animated:true completion:nil];
        return;
        
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:selectedPetTypeId,@"pet_type_id",selectedPetName,@"pet_name",selectedPetAge,@"pet_age",selectedPetSex,@"pet_sex",nil];
    
    [model_manager.petManager addPet:params withCompletionBlock:^(NSString* petId , NSString * message)
     {
         
         NSString *pet_id = [NSString stringWithFormat:@"%@",petId];
         if (![pet_id isEqualToString:@""])
         {
             // [self.navigationController popViewControllerAnimated:true];
             
             if (chosenImage)
             {
                 // show message
                 [self uploadPetImage:chosenImage withPetId:pet_id];
             }
             else{
                 [model_manager.petManager getPets:nil withCompletionBlock:^(BOOL success,NSString* message) {
                     if (success) {
                         
                     }
                 }];
                 [self.navigationController popViewControllerAnimated:true];
                 
             }
             
         }
         
     }];
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
