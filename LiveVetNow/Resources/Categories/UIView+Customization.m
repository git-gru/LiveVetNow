//
//  UIView+Customization.m
//  LiveVetNow
//
//  Created by Apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "UIView+Customization.h"

@implementation UIView (Customization)
+(UIView*)addBorderToView:(UIView*)view
{
    view.layer.borderColor = [UIColor colorWithRed:24.0f/255.0f green:57.0f/255.0f blue:74.0f/255.0f alpha:1.0f].CGColor;
    view.layer.borderWidth = 1.0f;
    view.layer.cornerRadius = 3.0f;
    return view;
}

+(UIView*)addShadowToView:(UIView*)view

{
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = CGSizeMake(2, 2);
    view.layer.shadowRadius = 5.0;
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    
    return view;
}



@end
