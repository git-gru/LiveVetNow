//
//  UIImageView+Customization.m
//  LiveVetNow
//
//  Created by Apple on 13/05/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "UIImageView+Customization.h"

@implementation UIImageView (Customization)
+(UIImageView*)roundImageViewWithBorderColourWithImageView:(UIImageView*)imageView withColor:(UIColor*)color
{
    imageView.layer.cornerRadius = imageView.frame.size.width/2.0f;
    imageView.layer.borderWidth = 1.0f;
    imageView.layer.borderColor = color.CGColor;
    imageView.clipsToBounds = true;
    return imageView;
    
}


@end
