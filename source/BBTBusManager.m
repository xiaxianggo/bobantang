//
//  BBTBusManager.m
//  bobantang
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <CRToast/CRToast.h>
#import "APService.h"
#import "BBTPreferences.h"
#import "BBTBusManager.h"
#import "BBTBus.h"

@interface BBTBusManager()

@property (strong, nonatomic) AFHTTPSessionManager *HTTPSessionManager;
@property (atomic) BOOL isRetriving;

@property (strong, atomic, readwrite) NSMutableDictionary *buses;
@property (nonatomic, readwrite) BBTBusManagerState state;

@property (strong, nonatomic, readwrite) NSArray *stationInfo;
@property (strong, nonatomic, readwrite) NSArray *stationNames;

@end


@implementation BBTBusManager
@synthesize buses = _buses;

static NSString * const baseURLString = @"http://bbt.100steps.net/go/data/";
//static NSString * const baseURLString = @"http://218.192.166.167:6767";
static NSString * const kFAKE_BUS1 = @"AAA";
static NSString * const kFAKE_BUS2 = @"BUSd";

+ (instancetype)sharedBusManager
{
    static BBTBusManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTBusManager alloc] init];
    });
    return _manager;
}

- (NSArray *)stationInfo
{
    if (!_stationInfo) {
        _stationInfo = @[@"图书馆，单车维修，华工正门，正门腐败一条街，华工科技园，天一快印，麟鸿楼，汕头校友楼学院），13号楼（食品学院）",
                         @"1号楼，文体中心，电讯楼，东区体育馆，游泳池",
                         @"百步梯，12号楼（工商管理学院），25号楼（物理实验）",
                         @"27号楼，3号楼（自动化学院），4号楼（数学学院、外语学院），华工校医院，东区饭堂，清真饭堂，五山地铁站",
                         @"逸夫人文馆，逸夫科学馆，励吾科技楼，计算机中心，9号楼（电力学院）",
                         @"水电中心，校园价，饭堂服务点，西湖苑，工商银行，西区体育场，中区饭堂，学六饭堂，邮局",
                         @"34号楼，轮滑场，排球场，西秀村小区（短租房，腐败一条街）",
                         @"天桥，多品美超市，宵夜集中地",
                         @"饭堂服务点，北一饭堂，继续教育学院",
                         @"北区图书馆，科技园一号楼、二号楼",
                         @"26号楼，北区校园价，打印店，电脑维修点，眼镜店，网络教育学院",
                         @"北二饭堂，单车维修，35号楼，北湖便利店，打印店，眼镜店，北区体育场，天河客运站"];
        
    }
    return _stationInfo;
}

- (NSArray *)stationNames
{
    if (!_stationNames) {
        _stationNames = @[@"北区总站", @"26号站", @"北湖南站", @"北门站",
                          @"修理厂站", @"附中站", @"西秀村站", @"西五站",
                          @"人文馆站", @"百步梯站", @"中山像站", @"南门总站"];
    }
    return _stationNames;
}

- (void)setBuses:(NSMutableDictionary *)buses
{
    _buses = buses;
}

- (NSMutableDictionary *)buses
{
    if (!_buses) {
        _buses = [[NSMutableDictionary alloc] init];
    }
    return _buses;
}

#define NETWORK_BEAT_INTERVAL 7.6 //seconds
-(id)init
{
    self = [super init];
    if (!self) return nil;
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    self.HTTPSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    self.HTTPSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.isRetriving = NO;
    [self updateBusData];
    [NSTimer scheduledTimerWithTimeInterval:NETWORK_BEAT_INTERVAL
                                     target:self
                                   selector:@selector(updateBusData)
                                   userInfo:nil
                                    repeats:YES];
    return self;
}

- (void)updateBusData
{
    if (self.isRetriving) {
        return;
    } else {
        [self retrieveBusData];
    }
}

- (void)retrieveBusData
{
    self.isRetriving = YES;
    [self.HTTPSessionManager GET:@"" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self updateBusesWithBusData:responseObject];
        self.state = [self runningBusCount] == 0 ? BBTBusManagerStateAllStop : BBTBusManagerStateNormal;
        [self postBusDataNotification];
        self.isRetriving = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.state = BBTBusManagerStateNetWorkError;
        [self postBusDataNotification];
        self.isRetriving = NO;
    }];
}


- (void)updateBusesWithBusData:(id)busData
{
    if (busData && [busData isKindOfClass:[NSDictionary class]]) { // validate the data send from the server.
        
        __block BOOL noValidBusFlag = YES;
        [(NSDictionary *)busData
         enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *key, NSDictionary *busDic, BOOL *stop) {
             // ignore the fake buses
             if ([key isEqualToString:kFAKE_BUS1] ||
                 [key isEqualToString:kFAKE_BUS2]) {
                 return ;
             }
             NSError *error = nil;  //TODO handle this error
             BBTBus *bus = [[BBTBus alloc] initWithDictionary:busDic error:&error];
             if (error) {
                 NSLog(@"bus data parse err: %@", error);
                 *stop = YES;
                 return;
             }
             [self.buses setObject:bus forKey:key];
             if (!bus.stop && !bus.fly) {
                 noValidBusFlag = NO;
             }
         }];
        self.state = noValidBusFlag ? BBTBusManagerStateAllStop : BBTBusManagerStateNormal;
    }
}

- (void)postBusDataNotification
{
    static NSString *notifName = @"BBTBusDataNotif";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self userInfo:nil];
}

- (NSUInteger)runningBusCount
{
    NSUInteger count = 0;
    for (NSString *key in [self.buses allKeys]) {
        BBTBus *bus = self.buses[key];
        if (!bus.stop && !bus.fly) {
            count += 1;
        }
    }
    return count;
}

- (NSDate *)latestStopBusTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    for (BBTBus *bus in [self.buses allValues]) {
        if (bus.stopAtFinalStation) {
            if ([bus.updateAt compare:date] == NSOrderedDescending) {
                date = bus.updateAt;
            }
        }
    }
    return date;
}

#pragma mark - Bus Station Notifications

- (void)updateBusStationNotificationSetting
{
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    
    if (preferences.busNotifActive) {
        NSInteger stationIndex = preferences.busNotifStationIndex;
        NSInteger direction = preferences.busNofitDirectionNorth;
        NSString *tag;
        NSSet *tags;
        
        if (stationIndex == 0) {
            tag = @"10";
        } else if (stationIndex == 11) {
            tag = @"011";
        } else {
            tag = [NSString stringWithFormat:@"%ld%ld", (long)direction, (long)stationIndex];
        }
        NSLog(@"%@", tag);

        tags = [NSSet setWithObject:tag];
        [APService setTags:tags callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    } else {
        // [NSSet set] return a empty set, used for setting tags to nothing.
        [APService setTags:[NSSet set] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    }
    
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
    NSLog(@"station notification setting changed.");
    
    NSString *toastText = iResCode == 0 ? @"到站提醒设置已更改" : @"到站提醒设置失败 :(";
    UIColor *tostColor = iResCode == 0 ? [UIColor BBTSusscessfulGreen] : [UIColor redColor];
    NSDictionary *options = @{
                              kCRToastTextKey :toastText,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : tostColor,
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
    if (iResCode != 0) {
        [BBTPreferences sharedInstance].busNotifActive = NO;
    }
    
    static NSString *notifName = @"BBTBusStationNotifDidChange";
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self userInfo:nil];
}

//- (void)didUpdateStationNotification:(NSInteger )iResCode tags:(NSSet*)tags alias:(NSString*)alias
//{
//    NSLog(@"station notification setting changed.");
//    NSLog(@"%d, tags: %@, alias: %@.", iResCode, tags, alias);
//    
//    static NSString *notifName = @"BBTBusStationNotifDidChange";
//    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self userInfo:nil];
//}

@end
