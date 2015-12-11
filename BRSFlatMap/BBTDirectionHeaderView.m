//
//  BBTDirectionHeaderView.m
//  bobantang
//
//  Created by Xia Xiang on 9/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTDirectionHeaderView.h"

@interface BBTDirectionHeaderView()



@end

@implementation BBTDirectionHeaderView

- (id)init
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BBTDirectionHeaderView" owner:nil options:nil];
    id mainView = [views firstObject];
    
    return mainView;
}

@end
