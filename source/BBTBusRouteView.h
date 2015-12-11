//
//  BBTBusRouteView.h
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTBusRouteView : UIView

@property (strong, nonatomic) NSMutableArray *greenCircles;
@property (strong, nonatomic) NSMutableArray *violetCircles;

- (instancetype)initWithFrame:(CGRect)frame Count:(NSUInteger)count;
@end
