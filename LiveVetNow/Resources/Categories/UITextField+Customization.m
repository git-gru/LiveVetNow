//
//  UITextField+Customization.m
//  LiveVetNow
//
//  Created by Apple on 14/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "UITextField+Customization.h"

@implementation UITextField (Customization)

+(UITextField*)addLayerToTextField:(UITextField*)textField
{
    UIColor *color = [UIColor lightTextColor];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.0f;
    border.borderColor = [UIColor lightTextColor].CGColor;
    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = borderWidth;
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;
    return textField;
}


@end
