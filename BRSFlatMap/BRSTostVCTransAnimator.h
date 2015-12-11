//
//  BRSPlaceVCTransAnimator.h
//  bobantang
//
//  Created by Xia Xiang on 8/27/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRSTostVCTransAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL presenting;
@property (nonatomic) CGFloat tostHeight;
@end
