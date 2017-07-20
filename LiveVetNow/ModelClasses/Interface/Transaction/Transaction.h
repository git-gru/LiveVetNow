//
//  Transaction.h
//  LiveVetNow
//
//  Created by apple on 03/06/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject

@property (strong,nonatomic) NSString *txn_id;
@property (strong,nonatomic) NSString *doctor_name;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSString *apt_datetime;
@property (strong,nonatomic) NSString *txn_date;
@property (strong,nonatomic) NSString *txn_amount;
@property (strong,nonatomic) NSString *currency;

@end
