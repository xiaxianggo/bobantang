//
//  BBTEmptyToolbar.m
//  bobantang
//
//  Created by Xia Xiang on 9/8/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTEmptyToolbar.h"

@implementation BBTEmptyToolbar

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.translucent = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Nothing to draw, an empty toolbar to contain a UIBarButtonItem in order to add to UIView
}


@end
