//
//  PetListingViewController.m
//  LiveVetNow
//
//  Created by Apple on 24/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "PetListingViewController.h"
#import "PetListingTableViewCell.h"
#import "Constants.h"
#import "UIButton+Customization.h"
#import "Pet.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AddPetViewController.h"
#import "DoctorProfleEditViewController.h"
@interface PetListingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    
    IBOutlet UITableView *tblViewPetListing;
    
}

@end

@implementation PetListingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [model_manager.petManager getPets:nil withCompletionBlock:^(BOOL success,NSString* message) {
        if (success) {
            
            [tblViewPetListing reloadData];
        }
    }];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model_manager.petManager.arrayPets.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *addMorePetsCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomAddMorePetCell];
    
    UIButton *addMorePet = [addMorePetsCell.contentView viewWithTag:1];
    
    addMorePet = [UIButton addBorderToButton:addMorePet withBorderColour:[UIColor colorWithRed:35.0/255.0 green:192.0/255.0 blue:104.0/255.0 alpha:1]];
    if (indexPath.row == model_manager.petManager.arrayPets.count) {
        return addMorePetsCell;
    }
    else {
        PetListingTableViewCell *customListingCell = (PetListingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kcustomPetListingCell];
        Pet *currentPet;
        currentPet = [model_manager.petManager.arrayPets objectAtIndex:indexPath.row];
        if (currentPet != nil) {
            [customListingCell.imgViewPet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",currentPet.pet_host,currentPet.pet_image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                {
                    customListingCell.imgViewPet.contentMode = UIViewContentModeScaleToFill;
                    customListingCell.imgViewPet .image = image;
                }
                else
                    customListingCell.imgViewPet .image = [UIImage imageNamed:@"dummyDog"];
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            customListingCell.lblPetName.text = currentPet.pet_name;
            customListingCell.lblPetInfo.text = [NSString stringWithFormat:@"%@-%@-%@MONTHS",[currentPet.pet_type capitalizedString],[currentPet.pet_sex capitalizedString],[currentPet.pet_age capitalizedString]];
        }
        return customListingCell;
    }
}

- (IBAction)btnAddnewPetAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PetsListing" bundle:nil];
    AddPetViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"AddPetViewController"];
    [self.navigationController pushViewController:objPetListing animated:true];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (model_manager.petManager.arrayPets.count !=  indexPath.row)
    {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
    
    DoctorProfleEditViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"ProfileEdit"];
    
    obj.editType = @"Pet";
    obj.currentPet = [model_manager.petManager.arrayPets objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:obj animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    
}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (model_manager.petManager.arrayPets.count ==  indexPath.row)
    {
    return false;
    }
    else{
        
        return  true;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Pet *toDeletePet = [model_manager.petManager.arrayPets objectAtIndex:indexPath.row];
    [model_manager.petManager deletePet:toDeletePet.pet_id withCompletionBlock:^(BOOL success,NSString* message) {
        if (success) {
            
            [model_manager.petManager.arrayPets removeObjectAtIndex:indexPath.row];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

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
