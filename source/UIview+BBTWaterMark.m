//
//  BBTWaterMark.m
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIView+BBTWaterMark.h"

@implementation UIView (BBTWaterMark)

+ (UIView *)BBTwaterMarkViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UIImageView *waterMarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waterMark"]];
    [view addSubview:waterMarkImageView];
    return view;
}
@end
