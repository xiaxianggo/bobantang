//
//  BBT3DMapViewController.h
//  bobantang
//
//  Created by Xia Xiang on 8/30/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BBTMapViewController.h"
#import "BBTMapContainerVC.h"
#import <UIKit/UIKit.h>

@interface BBT3DMapViewController : BBTMapViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic, weak) BBTMapContainerVC *mapContainerVC;
@end
