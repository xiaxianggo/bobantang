//
//  BBTAboutViewController.m
//  bobantang
//
//  Created by Xia Xiang on 9/26/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTAboutViewController.h"
#import "UIView+BBTWaterMark.h"
@implementation BBTAboutViewController

#define BBT_LOGO_UP_PADDING 121.0f
- (void)loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat screenWidth = appFrame.size.width;
    CGFloat screenHeight = appFrame.size.height;
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    self.view = ({
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:[UIView BBTwaterMarkViewWithFrame:appFrame]];
        
        UIImage *logoImage = [UIImage imageNamed:@"bbtlogovertical"];
        UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
        logoView.center = CGPointMake(screenWidth/2, naviBarHeight + statusBarHeight + BBT_LOGO_UP_PADDING);
        [view addSubview:logoView];
        
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, logoView.center.y + logoView.frame.size.height / 4.0f, screenWidth, 42.0f)];
        versionLabel.textAlignment = NSTextAlignmentCenter;
        versionLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:23.0f];
        versionLabel.text = @"2.3.3";
        [view addSubview:versionLabel];
        
        CGRect bbtLoabelFrame = CGRectMake(0.0f, screenHeight - tabBarHeight - 33.0f, screenWidth, 23.0f);
        UILabel *bbtLabel = [[UILabel alloc] initWithFrame:bbtLoabelFrame];
        bbtLabel.textAlignment = NSTextAlignmentCenter;
        bbtLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        bbtLabel.text = @"华南理工大学百步梯学生创新中心 诚意出品";
        
        CGRect copyrightLabelFrame = CGRectMake(0.0f, screenHeight - tabBarHeight - 7.0f, screenWidth, 23.0f);
        UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:copyrightLabelFrame];
        copyrightLabel.textAlignment = NSTextAlignmentCenter;
        copyrightLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0f];
        copyrightLabel.text = @"Copyright © 2014 bbt.100steps.net";
        
        [view addSubview:bbtLabel];
        [view addSubview:copyrightLabel];
        view;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于";
    
}

@end
