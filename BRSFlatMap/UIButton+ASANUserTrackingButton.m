//
//  UIButton+ASANUserTrackingButton.m
//  bobantang
//
//  Created by Xia Xiang on 9/8/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIButton+ASANUserTrackingButton.h"
#import "UIImage+BBTSetAlpha.h"
@implementation UIButton (ASANButton)

+ (UIButton *)ASANUserTrackingButtonWithFrame:(CGRect)frame
{
    //User Heading Button states images
    UIImage *buttonArrow = [UIImage imageNamed:@"position"];
    
    //Configure the button
    UIButton *userHeadingBtn = [UIButton ASANRoundRectButtonWithFrame:frame image:buttonArrow];

    return userHeadingBtn;
}

+ (UIButton *)ASANRoundRectButtonWithFrame:(CGRect)frame image:(UIImage *)image
{
    UIButton *button = [UIButton ASANRoundRectButtonWithFrame:frame];
    [button setImage:image forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)ASANRoundRectButtonWithFrame:(CGRect)frame title:(NSString *)title
{
    UIButton *button = [UIButton ASANRoundRectButtonWithFrame:frame];
    button.titleLabel.font = [UIFont fontWithName:@"Arial" size:16.0f];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (void)changeImageTo:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

- (void)changeTitleTo:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

+ (UIButton *)ASANRoundRectButtonWithFrame:(CGRect)frame
{
    UIImage *backgourndImage = [UIImage imageNamed:@"blueRoundRect"];
    UIImage *backgourndImageHighlight = [UIImage imageNamed:@"blueRoundRect"];
    
    //Configure the button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //Add state images
    [button setBackgroundImage:backgourndImage forState:UIControlStateNormal];
    [button setBackgroundImage:backgourndImageHighlight forState:UIControlStateHighlighted];
    
    //Button shadow
    button.frame = frame;
    [button sizeToFit];
    return button;

}
@end
