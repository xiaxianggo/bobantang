//
//  UIViewController+BBTAppRootVC.m
//  bobantang
//
//  Created by Xia Xiang on 8/30/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BBTBusViewController.h"
#import "BBTMapContainerVC.h"
#import "BBTSettingViewController.h"

#import "UIViewController+BBTAppRootVC.h"

@implementation UIViewController (BBTAppRootVC)

+ (UITabBarController *)BBTAppRootViewController
{
    BBTBusViewController *busViewController = [[BBTBusViewController alloc] init];
    UINavigationController *busNavigationController = [[UINavigationController alloc] initWithRootViewController:busViewController];
    busNavigationController.title = @"校巴";
    busNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"校巴" image:[UIImage imageNamed:@"busTab"] tag:0];
    
    BBTMapContainerVC *mapViewController = [[BBTMapContainerVC alloc] init];
    mapViewController.title = @"地图";
    UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    mapNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"地图" image:[UIImage imageNamed:@"mapTab"] tag:0];

    
    BBTSettingViewController *settingViewController = [[BBTSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingViewController.title = @"设置";
    UINavigationController *settingNaviVC = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    settingNaviVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"gearTab"] tag:0];

    UITabBarController *tabViewController = [[UITabBarController alloc] init];
    [tabViewController setViewControllers:@[busNavigationController, mapNavigationController, settingNaviVC] animated:YES];
    return tabViewController;
}
@end
