//
//  BRSPlaceVCTransAnimator.m
//  bobantang
//
//  Created by Xia Xiang on 8/27/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIViewController+ViewForTransitionContext.h"
#import "BRSTostVCTransAnimator.h"

@implementation BRSTostVCTransAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toControllerViewForTransition = [toViewController viewForTransitionContext:transitionContext];
    UIView *fromControllerViewForTransition = [fromViewController viewForTransitionContext:transitionContext];

    if (self.presenting) {
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = toControllerViewForTransition.frame;
        endFrame.origin.y = appFrame.size.height - self.tostHeight;
        
        [[transitionContext containerView] addSubview:fromViewController.view];
        [[transitionContext containerView] addSubview:toControllerViewForTransition];
        CGRect startFrame = endFrame;
        startFrame.origin.y += self.tostHeight;
        
        toControllerViewForTransition.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.8f
              initialSpringVelocity:0.5f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             //fromControllerViewForTransition.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                             toControllerViewForTransition.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             NSLog(@"presented");
                         }];
    }
    else {
        CGRect endFrame = fromControllerViewForTransition.frame;
        endFrame.origin.y += endFrame.size.height;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromControllerViewForTransition.frame = endFrame;
        } completion:^(BOOL finished) {
            [[[UIApplication sharedApplication] keyWindow] addSubview:toViewController.view];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            NSLog(@"finish");
        }];
    }
}

@end
