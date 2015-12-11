//
//  UILabel+BBTBusMessageLabel.m
//  bobantang
//
//  Created by Xia Xiang on 8/22/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UILabel+BBTBusMessageLabel.h"

@implementation UILabel (BBTBusMessageLabel)

+ (UILabel *)BBTBusMessageLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.86f;
    return label;
}
@end
