//
//  BBTBus.m
//  bobantang
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTBus.h"


@interface BBTBus()

/* bus info */
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSDate *updateAt;   //the time stamp for the bus

/* bus state */
@property (nonatomic, getter = isStop, readwrite) BOOL stop;
@property (nonatomic, getter = isFly, readwrite) BOOL fly;   // indicate if bus is on its normal routine

/* bus running progress */
@property (strong, nonatomic, readwrite) NSString *stationName;
@property (nonatomic, readwrite) NSUInteger stationIndex;
@property (nonatomic, readwrite) double percent;
@property (nonatomic, readwrite) BOOL headingSouth;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longitude;

@end


@implementation BBTBus

- (BBTBusDirection)direction
{
    return self.headingSouth ? BBTBusDirectionSourth : BBTBusDirectionNorth;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (BOOL)isBroken
{
    return self.stop && !(self.stationIndex != 1);
}

- (BOOL)stopAtFinalStation
{
    return self.stop && (self.stationIndex == 1) && !self.fly;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    self = [super initWithDictionary:dict error:err];
    if (!self) return nil;
    
    _retrievedAt = [NSDate date];
    
    return self;
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"Name": @"name",
                                                       @"Direction": @"headingSouth",
                                                       @"Time": @"updateAt",
                                                       @"Stop": @"stop",
                                                       @"Station" : @"stationName",
                                                       @"StationIndex" : @"stationIndex",
                                                       @"Percent" : @"percent",
                                                       @"Fly" : @"fly",
                                                       @"Latitude" : @"latitude",
                                                       @"Longitude" : @"longitude"
                                                       }];
}

@end
