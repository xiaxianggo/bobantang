//
//  BBTMapViewController.h
//  bobantang
//
//  Created by Xia Xiang on 8/26/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTMapContainerVC : UIViewController
@property (nonatomic, readonly) CGRect buttonGroupRect;
- (void)fallbackToFlatMap;
@end
