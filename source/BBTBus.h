//
//  BBTBus.h
//  bobantang
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
@import CoreLocation;
#import <JSONModel.h>

@interface BBTBus : JSONModel

/* bus info */
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSDate *updateAt;   //the time stamp for the bus

/* bus state */
@property (nonatomic, getter = isStop, readonly) BOOL stop;
@property (nonatomic, getter = isFly, readonly) BOOL fly;   // indicate if bus is on its normal routine

/* bus running progress */
@property (strong, nonatomic, readonly) NSString *stationName;
@property (nonatomic, readonly) NSUInteger stationIndex;
@property (nonatomic, readonly) double percent;
@property (nonatomic, readonly) BOOL headingSouth;
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

@property (nonatomic, readonly) BBTBusDirection direction;
@property (strong, nonatomic, readonly) NSDate *retrievedAt;
// time when we retrived the bus info, different from updateAt. use this to determine whether the bus info is out of date.

- (BOOL)stopAtFinalStation;
- (BOOL)isBroken;

- (CLLocationCoordinate2D)coordinate;

@end
