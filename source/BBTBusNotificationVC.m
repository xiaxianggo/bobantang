//
//  BBTBusNotificationVC.m
//  bobantang
//
//  Created by Xia Xiang on 10/13/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BBTBusManager.h"
#import "BBTPreferences.h"
#import "BBTBusNotificationVC.h"

@interface BBTBusNotificationVC () <RETableViewManagerDelegate>
@property (strong, nonatomic) RETableViewManager *tableViewManager;

@property (nonatomic, strong) REBoolItem *busNotificationActiveItem;
@property (nonatomic, strong) RESegmentedItem *busNotificationDirectionItem;
@property (nonatomic, strong) REPickerItem *busNotificationStationPickerItem;

@end

@implementation BBTBusNotificationVC


- (RESegmentedItem *)busNotificationDirectionItem
{
    if (!_busNotificationDirectionItem) {
        BBTPreferences *preferences = [BBTPreferences sharedInstance];

        NSInteger notifDirectionSettingValue = preferences.busNofitDirectionNorth ? 0 : 1;
        void (^switchValueChangeHandler)(RESegmentedItem *item)  = ^(RESegmentedItem *item) {
            NSLog(@"bus notif direction is %ld", (long)item.value);
            preferences.busNofitDirectionNorth = (item.value == 0) ? YES : NO;
        };
        _busNotificationDirectionItem = [RESegmentedItem itemWithTitle:@"方向"
                                                    segmentedControlTitles:@[@"北区总站方向", @"南门总站方向"]
                                                                     value:notifDirectionSettingValue
                                                  switchValueChangeHandler:switchValueChangeHandler];
    }
    
    return _busNotificationDirectionItem;
}

- (REPickerItem *)busNotificationStationPickerItem
{
    if (!_busNotificationStationPickerItem) {
        BBTPreferences *preferences = [BBTPreferences sharedInstance];
        NSArray *stations = [[BBTBusManager sharedBusManager].stationNames copy];
        NSLog(@"bus notif station index is %ld", (long)preferences.busNotifStationIndex);
        NSString *notifStationSettingValue = stations[[stations count] - 1 - preferences.busNotifStationIndex];
        _busNotificationStationPickerItem = [REPickerItem itemWithTitle:@"提醒站点"
                                                                      value:@[notifStationSettingValue]
                                                                placeholder:nil
                                                                    options:@[stations]];
        _busNotificationStationPickerItem.inlinePicker = YES;
        _busNotificationStationPickerItem.onChange = ^(REPickerItem *item) {
            NSInteger stationCount = [item.options[0] count];
            preferences.busNotifStationIndex = stationCount - 1 - [item.options[0] indexOfObject:item.value[0]];
        };
    }
    return _busNotificationStationPickerItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"校巴设置";
    
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    
    self.tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    //__block typeof(self) weakSelf = self;
    
    RETableViewSection *busSettingSection = [RETableViewSection sectionWithHeaderTitle: @"校巴到站提醒设置"];
    busSettingSection.footerView = ({
        CGRect frame = CGRectMake(10.0f, 4.0f, 300.0f, 15.0f);
        UIView *footerView = [[UIView alloc] initWithFrame:frame];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:frame];
        footerLabel.text = @"校巴即将到达设定的站点时会收到提醒。";
        footerLabel.textColor = [UIColor grayColor];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
        [footerView addSubview:footerLabel];

        CGRect frame2 = CGRectMake(10.0f, 19.0f, 300.0f, 15.0f);
        UILabel *footerLabel2 = [[UILabel alloc] initWithFrame:frame2];
        footerLabel2.text = @"该功能需要网络连接，提醒信息仅供参考。";
        footerLabel2.textColor = [UIColor grayColor];
        footerLabel2.backgroundColor = [UIColor clearColor];
        footerLabel2.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
        [footerView addSubview:footerLabel2];
        footerView;
    });
    [self.tableViewManager addSection:busSettingSection];
    
    // active setting
    self.busNotificationActiveItem = [REBoolItem itemWithTitle:@"到站提醒" value:preferences.busNotifActive switchValueChangeHandler:^(REBoolItem *item) {
        NSLog(@"bus notif switch is %d", item.value);
        preferences.busNotifActive = item.value;
        // TODO: this doesn't work.
        if (preferences.busNotifActive) {
            self.busNotificationDirectionItem.selectionStyle = UITableViewCellSelectionStyleDefault;
            self.busNotificationStationPickerItem.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else {
            self.busNotificationDirectionItem.selectionStyle = UITableViewCellSelectionStyleNone;
            self.busNotificationStationPickerItem.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }];
    [busSettingSection addItem:self.busNotificationActiveItem];
    if (preferences.busNotifActive) {
        self.busNotificationDirectionItem.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.busNotificationStationPickerItem.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        self.busNotificationDirectionItem.selectionStyle = UITableViewCellSelectionStyleNone;
        self.busNotificationStationPickerItem.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //direction setting
    [busSettingSection addItem:self.busNotificationDirectionItem];
    
    // station index setting
    [busSettingSection addItem:self.busNotificationStationPickerItem];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[BBTBusManager sharedBusManager] updateBusStationNotificationSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
