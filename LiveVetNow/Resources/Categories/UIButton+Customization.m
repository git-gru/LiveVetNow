//
//  UIButton+Customization.m
//  LiveVetNow
//
//  Created by Apple on 17/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "UIButton+Customization.h"

@implementation UIButton (Customization)
+(UIButton*)addBorderToButton:(UIButton*)button withBorderColour:(UIColor*)color
{
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1.0f;
    //button.layer.cornerRadius = 5.0f;
    return button;
}

@end
