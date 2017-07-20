//
//  FindYourVetViewController.m
//  LiveVetNow
//
//  Created by apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "FindYourVetViewController.h"
#import "FindYourVetTableViewCell.h"
#import "VetProfileForPetOwnerViewController.h"
#import "Constants.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "StartCallViewController.h"
#import "ScheduleMeetingViewController.h"
#import "UIImageView+Customization.h"
#import "ViewController.h"
#import "ReviewViewController.h"
#import "MBProgressHUD.h"

@interface FindYourVetViewController () {
    
    __weak IBOutlet UISegmentedControl *segmentedControl;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UITableView *tableViewVet;
    BOOL isSearchPhase;
    NSMutableArray *arrSearchResult;
    NSString *appointmentID;
    Vet *localVet;
    IBOutlet NSLayoutConstraint *segmentedControlView;
    
    IBOutlet NSLayoutConstraint *searchBarHeight;
}

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation FindYourVetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    model_manager.vetManager.vetManagerDelegate = self;
    arrSearchResult = [NSMutableArray new];
    isSearchPhase = NO;
    
    if ([self.type isEqualToString:@"emergency"])
    {
        
        segmentedControl.selectedSegmentIndex = 1;
      
        segmentedControlView.constant = 0;
        searchBarHeight.constant = 0;
        
    }
    
    [self loadViews];
    [self getVetList];
    appointmentID = @"";
   
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
    [tableViewVet reloadData];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark PubPresenceDelegate
-(void)notifyVetStatus {
    [tableViewVet reloadData];
}

#pragma mark Custom Button Methods


-(void)videoCallButtonAction : (UIButton*)sender {
    
    // if (kAppDelegate.isInternetReachable)//If Internet available
    // {
    
    
    // }
    // else
    //  [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
    
    // getting indexpath from selected button
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewVet];
    NSIndexPath *indexPath = [tableViewVet indexPathForRowAtPoint:rootViewPoint];
    
    Vet *selectedVet = [self getVetAtSelectedIndex:indexPath];
    if (selectedVet != nil) {
        localVet = selectedVet;
        [self showAlert:@"Are you sure?"];
    }
}

-(void)bookEmergencyAppointment
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:localVet.vetId,@"doctor_id",@"emergency",@"request_type",@"1",@"vet_detail_id",@"Answered",@"ques3",@"Answered",@"ques2",@"Answered",@"ques1",nil];
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    [model_manager.appointment_Manager bookAppointmentWithParams:params withHandler:^(BOOL success,NSString *Id,NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            appointmentID = Id;
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ReviewAndPay" bundle:nil];
            ReviewViewController *obj = [storyboard instantiateInitialViewController];
            obj.appointmentID = appointmentID;
            obj.currentVet = localVet;
            [self.navigationController pushViewController:obj animated:true];
        }
    }];
}

-(void)showAlert:(NSString*)message
{
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

-(void)scheduleButtonAction:(UIButton*)sender {
    
    // if (kAppDelegate.isInternetReachable)//If Internet available
    // {
    //  }
    // else
    //  [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
    
    // getting indexpath from selected button
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:tableViewVet];
    NSIndexPath *indexPath = [tableViewVet indexPathForRowAtPoint:rootViewPoint];
    
    Vet *selectedVet = [self getVetAtSelectedIndex:indexPath];
    if (selectedVet != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ScheduleMeeting" bundle:nil];
        ScheduleMeetingViewController *objPetListing = [storyboard instantiateViewControllerWithIdentifier:@"schedule"];
        objPetListing.selectedVet = selectedVet;
        //[self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController pushViewController:objPetListing animated:true];
    }
}

-(void)messageButtonAction:(UIButton*)sender {
    if (kAppDelegate.isInternetReachable)//If Internet available
    {
    }
    else
        [self presentViewController:[kAppDelegate showAlert:kInternetUnreachableMessage] animated:YES completion:nil];
}

#pragma mark - UISearchbar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    //contextView.hidden = YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)_searchText {
    if(_searchBar.text.length>0) {
        [self updateSearchResults];
    }
    else {
        isSearchPhase = NO;
        [tableViewVet reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar {
    isSearchPhase = NO;
    [tableViewVet reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar {
    //[self hideOverLayViews];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)_searchBar {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    if([_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
    }
    [_searchBar resignFirstResponder];
}
- (IBAction)valueChanged:(UISegmentedControl *)sender {
    if(searchBar.text.length>0)
        [self updateSearchResults];
    else
        isSearchPhase = NO;
    
    for (int i=0; i<[sender.subviews count]; i++) {
        if ([[sender.subviews objectAtIndex:i]isSelected]) {
            UIColor *tintcolor=[UIColor colorWithRed:25.0/255.0 green:69.0/255.0 blue:169.0/255.0 alpha:1];
            [[sender.subviews objectAtIndex:i] setTintColor:tintcolor];
            [sender.subviews objectAtIndex:i].layer.cornerRadius = segmentedControl.frame.size.height/2;
            [sender.subviews objectAtIndex:i].layer.masksToBounds = YES;
            
        }
        else {
            [[sender.subviews objectAtIndex:i] setTintColor:nil];
        }
    }
    [tableViewVet reloadData];
}

#pragma mark Custom Methods

-(void)getVetList {
    
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading..." animated:YES];
    
    if (![self.type isEqualToString:@"emergency"])
    {
    [model_manager.vetManager getVets:nil withCompletionBlock:^(BOOL success, NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            if (!kAppDelegate.isVet) {
                [model_manager.chatVendor subscribeToChannels:model_manager.vetManager.arrayVetsChannel presenceRequired:YES];
            }
            tableViewVet.hidden = NO;
            [tableViewVet reloadData];
        }
        else{
            [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
        }
    }];
    }
    else{
     
        
        [model_manager.vetManager getEmergencyVets:nil withCompletionBlock:^(BOOL success, NSString *message) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                if (!kAppDelegate.isVet) {
                    [model_manager.chatVendor subscribeToChannels:model_manager.vetManager.arrayVetsChannel presenceRequired:YES];
                    
                }
                tableViewVet.hidden = NO;
                [tableViewVet reloadData];
            }
            else{
                [self presentViewController:[kAppDelegate showAlert:message] animated:YES completion:nil];
            }
        }];
        
        
    }
}

-(NSMutableArray*) getRecommendedVets:(NSMutableArray*)array {
    NSMutableArray *tempArray = [NSMutableArray new];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
    if ([array filteredArrayUsingPredicate:predicate].count >0) {
        return [[array filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    return tempArray;
}

-(NSMutableArray*) getOtherVets:(NSMutableArray*)array {
    NSMutableArray *tempArray = [NSMutableArray new];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
    if ([array filteredArrayUsingPredicate:predicate].count >0) {
        tempArray = [[array filteredArrayUsingPredicate:predicate]mutableCopy];
    }
    return tempArray;
}

-(void)loadViews {
    if (self.showOnlineSegmentOnly) {
        [segmentedControl setSelectedSegmentIndex:1];
        segmentedControl.userInteractionEnabled = false;
    }
    tableViewVet.hidden = YES;
    // Search Bar Customization
    [searchBar setBackgroundImage:[[UIImage alloc]init]];
    [searchBar setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
    [searchBar setTintColor:[UIColor darkGrayColor]];
    [searchBar setBarTintColor:[UIColor darkGrayColor]];
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    
    // To change background color
    searchField.backgroundColor = [UIColor clearColor];
    searchField.font = [UIFont systemFontOfSize:18];
    searchField.borderStyle = UITextBorderStyleNone;
    [self customiseSegmentedControl];
}

- (IBAction)backButton:(id)sender {
    [model_manager.chatVendor unSubscribeToChannels:model_manager.vetManager.arrayVetsChannel];
    [model_manager.vetManager.arrayVetsOnlineRecommended removeAllObjects];
    [model_manager.vetManager.arrayVetsOnlineOthers removeAllObjects];
    [model_manager.vetManager.arrayVetsOfflineRecommended removeAllObjects];
    [model_manager.vetManager.arrayVetsOfflineOthers removeAllObjects];
    [model_manager.vetManager.arrayVets removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateSearchResults {
    [arrSearchResult removeAllObjects];
    if (segmentedControl.selectedSegmentIndex == 0) {
        isSearchPhase = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(vet.name contains[cd] %@)",searchBar.text];
        
        NSArray *filteredArray = [model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate];
        arrSearchResult = [filteredArray mutableCopy];
        [tableViewVet reloadData];
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
        isSearchPhase = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(vet.vetStatus== %@)",@"Online"];
        if ([model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
            NSMutableArray *arrayVetsOnline = [[model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate] mutableCopy];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(vet.name contains[cd] %@)",searchBar.text];
            NSArray *filteredArray = [arrayVetsOnline filteredArrayUsingPredicate:predicate];
            arrSearchResult = [filteredArray mutableCopy];
            
            [tableViewVet reloadData];
        }
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
        isSearchPhase = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(vet.vetStatus== %@)",@"Offline"];
        if ([model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
            NSMutableArray *arrayVetsOnline = [[model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate] mutableCopy];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(vet.name contains[cd] %@)",searchBar.text];
            NSArray *filteredArray = [arrayVetsOnline filteredArrayUsingPredicate:predicate];
            arrSearchResult = [filteredArray mutableCopy];
            
            [tableViewVet reloadData];
        }
    }
}

#pragma mark SegmentedControl Methods
-(void)customiseSegmentedControl {
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    // set first segment selected
    
    for (int i=0; i<[segmentedControl.subviews count]; i++)
    {
        if ([[segmentedControl.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor=[UIColor colorWithRed:25.0/255.0 green:69.0/255.0 blue:169.0/255.0 alpha:1];
            [[segmentedControl.subviews objectAtIndex:i] setTintColor:tintcolor];
            [segmentedControl.subviews objectAtIndex:i].layer.cornerRadius = segmentedControl.frame.size.height/2;
            [segmentedControl.subviews objectAtIndex:i].layer.masksToBounds = YES;
            
        }
        else
        {
            [[segmentedControl.subviews objectAtIndex:i] setTintColor:nil];
        }
    }
    
    
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0)
    {
        return 10;
    }
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableViewVet.frame.size.width, 30)];
    UILabel *lblVetTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 4, 200, 21)];
    UILabel *lblVetCount = [[UILabel alloc]initWithFrame:CGRectMake(tableViewVet.frame.size.width-110, 0, 100, 30)];
    if (section == 0) {
        lblVetTitle.text = @"RECOMMENDED";
        if (segmentedControl.selectedSegmentIndex == 0) {
            if(isSearchPhase) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getRecommendedVets:arrSearchResult].count];
                }
            }
            else if ([self getRecommendedVets:model_manager.vetManager.arrayVets] != nil) {
                lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getRecommendedVets:model_manager.vetManager.arrayVets].count];
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            if(isSearchPhase) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getRecommendedVets:arrSearchResult].count];
                }
            }
            else if([self getRecommendedVets:model_manager.vetManager.arrayVetsOnlineRecommended] != nil) {
                lblVetCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)model_manager.vetManager.arrayVetsOnlineRecommended.count];
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 2) {
            if(isSearchPhase) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getRecommendedVets:arrSearchResult].count];
                }
            }
            else if([self getRecommendedVets:model_manager.vetManager.arrayVetsOfflineRecommended] != nil) {
                lblVetCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)model_manager.vetManager.arrayVetsOfflineRecommended.count];
            }
        }
    }
    else {
        lblVetTitle.text = @"OTHER";
        if (segmentedControl.selectedSegmentIndex == 0) {
            if(isSearchPhase) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getOtherVets:arrSearchResult].count];
                }
            }
            else if ([self getOtherVets:model_manager.vetManager.arrayVets ] != nil) {
                lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getOtherVets:model_manager.vetManager.arrayVets].count];
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            if(isSearchPhase) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getOtherVets:arrSearchResult].count];
                }
            }
            else if ([self getOtherVets:model_manager.vetManager.arrayVetsOnlineOthers ] != nil) {
                lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getOtherVets:model_manager.vetManager.arrayVetsOnlineOthers].count];
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 2) {
            if(isSearchPhase) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getOtherVets:arrSearchResult].count];
                }
            }
            else if ([self getOtherVets:model_manager.vetManager.arrayVetsOfflineOthers] != nil) {
                lblVetCount.text = [NSString stringWithFormat:@"%lu",[self getOtherVets:model_manager.vetManager.arrayVetsOfflineOthers].count];
            }
        }
    }
    lblVetCount.textAlignment = NSTextAlignmentRight;
    
    UIView *viewSeparator = [[UIView alloc]initWithFrame:CGRectMake(15, 29, tableViewVet.frame.size.width-30, 1)];
    viewSeparator.backgroundColor = [UIColor lightGrayColor];
    
    [headerView addSubview:lblVetTitle];
    [headerView addSubview:lblVetCount];
    [headerView addSubview:viewSeparator];
    return headerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableViewVet.frame.size.width, 10)];
        footerView.backgroundColor = [UIColor lightGrayColor];
        footerView.alpha = 0.1;
        return footerView;
    }
    return [[UIView alloc]init];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (segmentedControl.selectedSegmentIndex == 0) {
        if(isSearchPhase) {
            if (section==0) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    return [self getRecommendedVets:arrSearchResult].count;
                }
            }
            else {
                if ([self getOtherVets:arrSearchResult] != nil) {
                    return [self getOtherVets:arrSearchResult].count;
                }
            }
        }
        else {
            if (section==0) {
                if ([self getRecommendedVets:model_manager.vetManager.arrayVets ] != nil) {
                    return [self getRecommendedVets:model_manager.vetManager.arrayVets ].count;
                }
            }
            else {
                if ([self getOtherVets:model_manager.vetManager.arrayVets ] != nil) {
                    return [self getOtherVets:model_manager.vetManager.arrayVets ].count;
                }
            }
        }
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        if(isSearchPhase) {
            if (section==0) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    return [self getRecommendedVets:arrSearchResult].count;
                }
            }
            else {
                if ([self getOtherVets:arrSearchResult] != nil) {
                    return [self getOtherVets:arrSearchResult].count;
                }
            }
        }
        else {
            if (section==0)
                return model_manager.vetManager.arrayVetsOnlineRecommended.count;
            else
                return model_manager.vetManager.arrayVetsOnlineOthers.count;
        }
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
        if(isSearchPhase) {
            if (section==0) {
                if ([self getRecommendedVets:arrSearchResult] != nil) {
                    return [self getRecommendedVets:arrSearchResult].count;
                }
            }
            else {
                if ([self getOtherVets:arrSearchResult] != nil) {
                    return [self getOtherVets:arrSearchResult].count;
                }
            }
        }
        else {
            if (section==0)
                return model_manager.vetManager.arrayVetsOfflineRecommended.count;
            else
                return model_manager.vetManager.arrayVetsOfflineOthers.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FindYourVetTableViewCell *findYourVetCell = (FindYourVetTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kFindYourVetTableViewCellIdentifier];
    //newCell.backgroundColor = [UIColor clearColor];
    
    //[findYourVetCell.imgViewVet layoutIfNeeded];
    
    findYourVetCell.imgViewVet = [UIImageView roundImageViewWithBorderColourWithImageView:findYourVetCell.imgViewVet withColor:[UIColor clearColor]];
    
    //    findYourVetCell.imgViewVet.layer.cornerRadius = findYourVetCell.imgViewVet.frame.size.width/2.0f;
    //    [findYourVetCell.imgViewVet.layer setBorderWidth:1.0f];
    //    [findYourVetCell.imgViewVet.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //    [findYourVetCell.imgViewVet.layer setMasksToBounds:YES];
    //    findYourVetCell.imgViewVet.clipsToBounds=YES;
    
    [findYourVetCell.btnVideoCall setTag:indexPath.row];
    [findYourVetCell.btnVideoCall addTarget:self action:@selector(videoCallButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [findYourVetCell.btnSchedule addTarget:self action:@selector(scheduleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    findYourVetCell.statusDot.layer.borderWidth = 2.0f;
    findYourVetCell.statusDot.layer.borderColor = [UIColor whiteColor].CGColor;


    [findYourVetCell.btnMessage addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //if (indexPath.row == 2) {
    //    findYourVetCell.customSeparator.hidden = true;
    // }
    // else {
    //   findYourVetCell.customSeparator.hidden = false;
    //}
    
    Vet *currentVet;
    if (indexPath.section == 0) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if(isSearchPhase)
                currentVet = ((Vet*)[arrSearchResult objectAtIndex:indexPath.row]);
            else {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                if ([model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
                    currentVet = ((Vet*)[[[model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
                else
                    return findYourVetCell;
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            if(isSearchPhase)
                currentVet = ((Vet*)[arrSearchResult objectAtIndex:indexPath.row]);
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOnlineRecommended.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                    if ([model_manager.vetManager.arrayVetsOnlineRecommended filteredArrayUsingPredicate:predicate].count >0) {
                        currentVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOnlineRecommended filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return findYourVetCell;
                }
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 2) {
            if(isSearchPhase)
                currentVet = ((Vet*)[arrSearchResult objectAtIndex:indexPath.row]);
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOfflineRecommended.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                    if ([model_manager.vetManager.arrayVetsOfflineRecommended filteredArrayUsingPredicate:predicate].count >0) {
                        currentVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOfflineRecommended filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return findYourVetCell;
                }
            }
        }
    }
    else if (indexPath.section == 1) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if(isSearchPhase)
                currentVet = ((Vet*)[arrSearchResult objectAtIndex:indexPath.row]);
            else {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                if ([model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
                    currentVet = ((Vet*)[[[model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
                else
                    return findYourVetCell;
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            if(isSearchPhase)
                currentVet = ((Vet*)[arrSearchResult objectAtIndex:indexPath.row]);
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOnlineOthers.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                    if ([model_manager.vetManager.arrayVetsOnlineOthers filteredArrayUsingPredicate:predicate].count >0) {
                        currentVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOnlineOthers filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                        
                    }
                    else
                        return findYourVetCell;
                }
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 2) {
            if(isSearchPhase)
                currentVet = ((Vet*)[arrSearchResult objectAtIndex:indexPath.row]);
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOfflineOthers.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                    if ([model_manager.vetManager.arrayVetsOfflineOthers filteredArrayUsingPredicate:predicate].count >0) {
                        currentVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOfflineOthers filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return findYourVetCell;
                }
            }
        }
    }
    
   // Vet *currentVet = [self getVetAtSelectedIndex:indexPath];;
    if (currentVet) {
        findYourVetCell.lblName.text = currentVet.name;
        findYourVetCell.lblSpeciality.text = currentVet.speciality_name;
        findYourVetCell.lblLocation.text = currentVet.state;
        [findYourVetCell.imgViewVet setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",host,currentVet.image_url]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
                findYourVetCell.imgViewVet.image = image;
            else
                findYourVetCell.imgViewVet.image = [UIImage imageNamed:@"DummyProfile"];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSLog(@"current vet status %@ for userID%@",currentVet.vetStatus,currentVet.vetId);
        //Vet online
        if ([currentVet.vetStatus isEqualToString:@"Online"]) {
            [findYourVetCell.btnVideoCall setImage:[UIImage imageNamed:@"VideoCall"] forState:UIControlStateNormal];
            findYourVetCell.statusDot.backgroundColor = [UIColor greenColor];
            
            findYourVetCell.btnVideoCall.userInteractionEnabled = YES;
        }
        //Vet offline
        else {
            [findYourVetCell.btnVideoCall setImage:[UIImage imageNamed:@"VideoCallWhite"] forState:UIControlStateNormal];
            findYourVetCell.statusDot.backgroundColor = [UIColor lightGrayColor];

            findYourVetCell.btnVideoCall.userInteractionEnabled = NO;
        }
    }
    //   [findYourVetCell.btnVideoCall setImage:[UIImage imageNamed:@"VideoCall"] forState:UIControlStateNormal];
    //   findYourVetCell.btnVideoCall.userInteractionEnabled = YES;
    
       findYourVetCell.btnVideoCall.hidden = true;
        findYourVetCell.btnSchedule.hidden = true;
        findYourVetCell.btnMessage.hidden = true;
    
    return findYourVetCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Vet *currentVet = [self getVetAtSelectedIndex:indexPath];
    if (currentVet != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kVetProfileForPetOwnerStoryboard bundle:nil];
        VetProfileForPetOwnerViewController *vetProfileForPetOwnerViewController = [storyboard instantiateViewControllerWithIdentifier:kVetProfileForPetOwnerStoryboardIdentifier];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setValue:@"Take's care of all concerns" forKey:@"comment"];
        [tempDict setValue:@"" forKey:@"image"];
        [tempDict setValue:@"Joe" forKey:@"name"];
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:tempDict];
        vetProfileForPetOwnerViewController.vetFeedback = tempArray;
        vetProfileForPetOwnerViewController.selectedVet = currentVet;
        vetProfileForPetOwnerViewController.type = self.type;
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        [self.navigationController pushViewController:vetProfileForPetOwnerViewController animated:YES];
    }
}

-(Vet*)getVetAtSelectedIndex:(NSIndexPath*)indexPath {
    Vet *foundVet;
    if (indexPath.section == 0) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if(isSearchPhase) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                if ([arrSearchResult filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[arrSearchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
            }
            else {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                if ([model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
                else
                    return nil;
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            if(isSearchPhase) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                if ([arrSearchResult filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[arrSearchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
            }
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOnlineRecommended.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                    if ([model_manager.vetManager.arrayVetsOnlineRecommended filteredArrayUsingPredicate:predicate].count >0) {
                        foundVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOnlineRecommended filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return nil;
                }
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 2) {
            if(isSearchPhase) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                if ([arrSearchResult filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[arrSearchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
            }
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOfflineRecommended.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                    if ([model_manager.vetManager.arrayVetsOfflineRecommended filteredArrayUsingPredicate:predicate].count >0) {
                        foundVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOfflineRecommended filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return nil;
                }
            }
        }
    }
    else if (indexPath.section == 1) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if(isSearchPhase) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                if ([arrSearchResult filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[arrSearchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
            }
            else {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                if ([model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[model_manager.vetManager.arrayVets filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
                else
                    return nil;
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            if(isSearchPhase) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                if ([arrSearchResult filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[arrSearchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
            }
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOnlineOthers.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                    if ([model_manager.vetManager.arrayVetsOnlineOthers filteredArrayUsingPredicate:predicate].count >0) {
                        foundVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOnlineOthers filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return nil;
                }
            }
        }
        else if (segmentedControl.selectedSegmentIndex == 2) {
            if(isSearchPhase) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"true"];
                if ([arrSearchResult filteredArrayUsingPredicate:predicate].count >0) {
                    foundVet = ((Vet*)[[[arrSearchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                }
            }
            else {
                if (indexPath.row<model_manager.vetManager.arrayVetsOfflineOthers.count) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRecommended CONTAINS[cd] %@",@"false"];
                    if ([model_manager.vetManager.arrayVetsOfflineOthers filteredArrayUsingPredicate:predicate].count >0) {
                        foundVet = ((Vet*)[[[model_manager.vetManager.arrayVetsOfflineOthers filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row]objectForKey:@"vet"]);
                    }
                    else
                        return nil;
                }
            }
        }
    }
    
    /*
    if (foundVet != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kVetProfileForPetOwnerStoryboard bundle:nil];
        VetProfileForPetOwnerViewController *vetProfileForPetOwnerViewController = [storyboard instantiateViewControllerWithIdentifier:kVetProfileForPetOwnerStoryboardIdentifier];
       
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setValue:@"dfghjklkjhgfdsdfghjklkhgfdsdfghjkhgfdsdfghjkljhgfqwertyuioplkjhgfdsazxcvbnm,lkjhgfdsaqwertyuio" forKey:@"comment"];
        [tempDict setValue:@"" forKey:@"image"];
        [tempDict setValue:@"Joe" forKey:@"name"];
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:tempDict];
        vetProfileForPetOwnerViewController.vetFeedback = tempArray;
        vetProfileForPetOwnerViewController.selectedVet = foundVet;
        vetProfileForPetOwnerViewController.type = self.type;
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        [self.navigationController pushViewController:vetProfileForPetOwnerViewController animated:YES];
    }
     */
    return foundVet;
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
