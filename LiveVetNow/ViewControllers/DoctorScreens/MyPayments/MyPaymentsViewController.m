//
//  MyPaymentsViewController.m
//  LiveVetNow
//
//  Created by Apple on 03/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "MyPaymentsViewController.h"
#import "UIView+Customization.h"
#import "Constants.h"
#import "Transaction.h"

@interface MyPaymentsViewController ()
{
    
    __weak IBOutlet UILabel *lblEarning;
    __weak IBOutlet UILabel *lblEarningWeek;
    IBOutlet UIView *thisWeekEarningView;
    
    IBOutlet UIView *totalEarningView;
}

@end

@implementation MyPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblEarning.text = model_manager.appointment_Manager.totalEarning;
    lblEarningWeek.text = model_manager.appointment_Manager.weeklyEarning;
}
- (IBAction)btnBackAction:(UIButton *)sender {
    
    
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - table view delegates and datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model_manager.appointment_Manager.arrayTransactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    UITableViewCell *customListingCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"customPaymentsCell"];
    Transaction *currentTransaction = [model_manager.appointment_Manager.arrayTransactions objectAtIndex:indexPath.row];
    UILabel *lblDate = (UILabel*)[customListingCell.contentView viewWithTag:1];
    UILabel *lblAmount = (UILabel*)[customListingCell.contentView viewWithTag:2];
    if (currentTransaction) {
        lblDate.text = [model_manager.appointment_Manager getDateStringFromDate:[model_manager.appointment_Manager dateFromTimestamp:currentTransaction.txn_date]];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:currentTransaction.currency];
        NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale displayNameForKey:NSLocaleCurrencySymbol value:currentTransaction.currency]];
        lblAmount.text = [NSString stringWithFormat:@"%@ %@",currencySymbol,currentTransaction.txn_amount];
    }
    return customListingCell;
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
