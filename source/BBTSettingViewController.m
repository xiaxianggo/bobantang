//
//  BBTSettingViewController.m
//  bobantang
//
//  Created by Xia Xiang on 8/30/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTSettingViewController.h"
#import "BBTBusManager.h"
#import "BBTBusNotificationVC.h"
#import "BBTAboutViewController.h"
#import "BBTFeedbackViewController.h"
#import "BBTTilesourceDownloadVC.h"

@interface BBTSettingViewController() <RETableViewManagerDelegate>
@property (strong, nonatomic) RETableViewManager *tableViewManager;
@end

@implementation BBTSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    
    self.tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    //__block typeof(self) weakSelf = self;
    
    
    // bus settings
    RETableViewSection *busSettingSection = [RETableViewSection sectionWithHeaderTitle: @"校巴设置"];
    [self.tableViewManager addSection:busSettingSection];
    [busSettingSection addItem:[RETableViewItem itemWithTitle:@"校巴到站提醒设置"
                                                accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                             selectionHandler:^(RETableViewItem *item) {
                                                 [item deselectRowAnimated:YES];
                                                 [self.navigationController pushViewController:[[BBTBusNotificationVC alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
                                             }]];
    
    // map settings
    RETableViewSection *mapResourceSection = [RETableViewSection sectionWithHeaderTitle:@"地图设置"];
    [self.tableViewManager addSection:mapResourceSection];
    
    [mapResourceSection addItem:[RETableViewItem itemWithTitle:@"2.5D地图包下载"
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                              selectionHandler:^(RETableViewItem *item) {
                                                  [item deselectRowAnimated:YES];
                                                  [self.navigationController pushViewController:[[BBTTilesourceDownloadVC alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
                                              }]];
    
    
    // feedbacks
    RETableViewSection *feedBackSection = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.tableViewManager addSection:feedBackSection];
    
    [feedBackSection addItem:[RETableViewItem itemWithTitle:@"意见反馈"
                                              accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                           selectionHandler:^(RETableViewItem *item) {
                                               [item deselectRowAnimated:YES];
                                               [self.navigationController pushViewController:[[BBTFeedbackViewController alloc] init] animated:YES];
                                           }]];
    [feedBackSection addItem:[RETableViewItem itemWithTitle:@"去 App Store 评分"
                                              accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                           selectionHandler:^(RETableViewItem *item) {
                                               [item deselectRowAnimated:YES];
                                               NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/bo-ban-tang/id625954338?ls=1&mt=8"];
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                                           }]];
    [feedBackSection addItem:[RETableViewItem itemWithTitle:@"关于"
                                              accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                           selectionHandler:^(RETableViewItem *item) {
                                               [self.navigationController pushViewController:[[BBTAboutViewController alloc] init] animated:YES];
                                           }]];
    
}

@end
