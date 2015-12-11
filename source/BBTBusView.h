//
//  BBTBusView.h
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTBusView : UIView

@property (nonatomic) BBTBusDirection direction;
@property (strong, nonatomic) UIImageView *busPic, *arrowView, *slashView;

@property (strong, nonatomic) CAAnimation *animationViewPosition;

- (id)initWithFrame:(CGRect)frame direction:(BBTBusDirection)direction;
@end
