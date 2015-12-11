//
//  BBTBusManager.h
//  bobantang
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>

@interface BBTBusManager : NSObject

+ (instancetype)sharedBusManager;   //singleton

@property (nonatomic, readonly) BBTBusManagerState state;
@property (strong, atomic, readonly) NSMutableDictionary *buses;

@property (strong, nonatomic, readonly) NSArray *stationInfo;
@property (strong, nonatomic, readonly) NSArray *stationNames;


- (void)updateBusData;
- (NSUInteger)runningBusCount;
- (NSDate *)latestStopBusTime;
- (void)updateBusStationNotificationSetting;

@end
