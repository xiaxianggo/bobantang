//
//  UIViewController+ViewForTransitionContext.h
//  bobantang
//
//  Created by Xia Xiang on 9/10/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ViewForTransitionContext)

- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
