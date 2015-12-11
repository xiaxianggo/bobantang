//
//  BBTBusViewController.m
//  bobantang
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "GmailLikeLoadingView.h"
#import "KGModal.h"

#import "UIView+BBTBusTimeTable.h"
#import "UILabel+BBTBusMessageLabel.h"
#import "UIView+BBTStationInfo.h"
#import "UIView+BBTWaterMark.h"
#import "BBTCountView.h"
#import "BBTBusClusterView.h"
#import "BBTBusManager.h"
#import "BBTBus.h"

#import "BBTBusViewController.h"

@interface BBTBusViewController () <BBTBusClusterViewDelegate>

@property (strong, nonatomic) UIView *waterMark;
@property (strong, nonatomic) BBTBusClusterView *busClusterView;

@property (strong, nonatomic) GmailLikeLoadingView *loadingView;
@property (strong, nonatomic) BBTCountView *busCountView;
@property (strong, nonatomic) UILabel *busMessageLabel;

@property (strong, nonatomic) UISlider *stationSlider;
@end

@implementation BBTBusViewController

#define LOADING_VIEW_SIZE 24.0f
- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *view = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = view;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat screenWidth = applicationFrame.size.width;
    CGFloat screenHeight = applicationFrame.size.height;
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat messageLabelHeight = 23.0f;

    /* add water mark */
    self.waterMark = [UIView BBTwaterMarkViewWithFrame:applicationFrame];
    [self.view addSubview:self.waterMark];
    
    /* add bus cluster view */
    CGFloat clusterY = naviBarHeight + statusBarHeight + messageLabelHeight;
    CGFloat clusterHeight = screenHeight - clusterY - tabBarHeight;
    CGRect frame = CGRectMake(0.0f, clusterY, screenWidth, clusterHeight);
    self.busClusterView = [[BBTBusClusterView alloc] initWithFrame:frame stationNames:[BBTBusManager sharedBusManager].stationNames];
    [self.view addSubview:self.busClusterView];
    
    /* add bus count view and loading view */
    CGFloat loadingViewY = clusterY + LOADING_VIEW_SIZE / 2.0f;        // same y position with bus cluster
    CGFloat loadingViewX = screenWidth - LOADING_VIEW_SIZE - LOADING_VIEW_SIZE / 2.0f;
    CGRect loadingViewFrame = CGRectMake(loadingViewX, loadingViewY, LOADING_VIEW_SIZE, LOADING_VIEW_SIZE);
    self.busCountView = [[BBTCountView alloc] initWithFrame:loadingViewFrame];
    self.loadingView = [[GmailLikeLoadingView alloc] initWithFrame:loadingViewFrame];
    [self.view addSubview:self.busCountView];
    [self.view addSubview:self.loadingView];
    
    /* add bus message label */
    CGFloat messageLabelY = naviBarHeight + statusBarHeight;
    CGRect messageLabelFrame = CGRectMake(0.0f, messageLabelY, screenWidth, messageLabelHeight);
    self.busMessageLabel = [UILabel BBTBusMessageLabelWithFrame:messageLabelFrame];
    [self.view addSubview:self.busMessageLabel];
    
//    self.stationSlider = ({
//        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(42.0f - (clusterHeight / 2.0f), clusterY + clusterHeight / 2.0f, clusterHeight, 42.0f)];
//        slider.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
//        slider.continuous = NO;
//        slider;
//    });
//    [self.view addSubview:self.stationSlider];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /* set up */
    self.title = @"校巴";
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    UIBarButtonItem *timeTableButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clock"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(popUpBusTimeTable)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(refresh)];
    refreshButton.imageInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -30.0f);
    //adjust the gap between these two buttons
    self.navigationItem.rightBarButtonItems = @[timeTableButton, refreshButton];
    
    self.busClusterView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* listen to bus data nofitication */
    static NSString *notifName = @"BBTBusDataNotif";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveBusDataNotif:)
                                                 name:notifName
                                               object:nil];
    
    /* start bus manager */
    [BBTBusManager sharedBusManager];
    [self.busClusterView restartBusAnimation];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.loadingView.isAnimating) {
        [self.loadingView startAnimating];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveBusDataNotif:(NSNotification *)notification
{
    //NSLog(@"did receive notif");
    [self.loadingView stopAnimating];
    switch ([BBTBusManager sharedBusManager].state) {
        case BBTBusManagerStateNormal: {
            [self.busClusterView updateBusPosition];
            [self.busCountView setState:BBTCountViewStateCounting
                                  Count:[[BBTBusManager sharedBusManager] runningBusCount]];
            [self.busCountView performFlashAnimation];
            self.busMessageLabel.hidden = YES;
            break;
        }
        case BBTBusManagerStateAllStop: {
            [self.busClusterView updateBusPosition];
            [self.busCountView setState:BBTCountViewStateOff];
            self.busMessageLabel.hidden = NO;
            NSDate *latestBusTime = [[BBTBusManager sharedBusManager] latestStopBusTime];
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            dateFormater.timeStyle = NSDateFormatterShortStyle;
            NSString *timeString = [dateFormater stringFromDate:latestBusTime];
            // TODO: maybe time is not correct
            self.busMessageLabel.text = [NSString stringWithFormat:@"☕上一班校巴已于 %@ 停站", timeString];
            break;
        }
        case BBTBusManagerStateNetWorkError: {
            [self. busClusterView updateBusPosition];
            [self.busCountView setState:BBTCountViewStateAlarm];
            self.busMessageLabel.text = @"😕获取校巴数据失败";
            self.busMessageLabel.hidden = NO;
            break;
        }
        default:
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - BBTBusClusterViewDelegate
- (NSArray *)busKeysForBBTBusClusterView:(BBTBusClusterView *)clusterView
{
    return [[BBTBusManager sharedBusManager].buses allKeys];
}

- (BOOL)BBTBusClusterView:(BBTBusClusterView *)clusterView shouldDisplayBus:(NSString *)busKey
{
    BBTBus *bus = [[BBTBusManager sharedBusManager].buses objectForKey:busKey];
    return !bus.fly && !bus.stop;
}

- (BBTBusViewPosition)BBTBusClusterView:(BBTBusClusterView *)clusterView locationForBus:(NSString *)busKey
{
    BBTBus *bus = [[BBTBusManager sharedBusManager].buses objectForKey:busKey];
    BBTBusViewPosition position;
    position.direction = bus.direction;
    position.percent = bus.percent;
    position.stationIndex = bus.stationIndex;
    return position;
}

- (void)BBTBusClusterView:(BBTBusClusterView *)clusterView didTapButtonAtIndex:(NSUInteger)index
{
    NSArray *stationsNames = [BBTBusManager sharedBusManager].stationNames;
    NSArray *stationInfo = [BBTBusManager sharedBusManager].stationInfo;
    if (index <= [stationsNames count]) {
        UIView *contentView = [UIView BBTStationInfoContentViewWithName:stationsNames[index]
                                                                   info:stationInfo[index]];
        [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
    }
}

#pragma mark
- (void)popUpBusTimeTable
{
    UIView *timeTableView = [UIView BBTTimeTableView];
    [[KGModal sharedInstance] showWithContentView:timeTableView andAnimated:YES];
}

- (void)refresh
{
    if (!self.loadingView.isAnimating) {
        [self.loadingView startAnimating];
    }
    
    /* update the bus info with a little delay to show the loading animation */
    BBTBusManager *manager = [BBTBusManager sharedBusManager];
    [NSTimer timerWithTimeInterval:1.3f
                            target:manager
                          selector:@selector(updateBusData)
                          userInfo:nil
                           repeats:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
