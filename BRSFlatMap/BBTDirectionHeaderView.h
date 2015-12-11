//
//  BBTDirectionHeaderView.h
//  bobantang
//
//  Created by Xia Xiang on 9/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTDirectionHeaderView : UIView
@property (weak, nonatomic) IBOutlet UITextField *startTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTextField;
@property (weak, nonatomic) IBOutlet UIButton *routeButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *hideDownArrowButton;
@end

