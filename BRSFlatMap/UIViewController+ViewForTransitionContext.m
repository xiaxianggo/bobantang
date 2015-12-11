//
//  UIViewController+ViewForTransitionContext.m
//  bobantang
//
//  Created by Xia Xiang on 9/10/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIViewController+ViewForTransitionContext.h"

@implementation UIViewController (ViewForTransitionContext)

- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        NSString *key = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] == self ? UITransitionContextFromViewKey : UITransitionContextToViewKey;
        return [transitionContext viewForKey:key];
    } else {
        return self.view;
    }
#else
    return self.view;
#endif
}

@end
