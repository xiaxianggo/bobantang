//
//  BBTMarco.h
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#ifndef bobantang_BBTMarco_h
#define bobantang_BBTMarco_h


typedef enum : NSUInteger {
    BBTBusManagerStateNormal,
    BBTBusManagerStateAllStop,
    BBTBusManagerStateNetWorkError
} BBTBusManagerState;

typedef enum : NSUInteger {
    BBTBusDirectionNorth,
    BBTBusDirectionSourth
} BBTBusDirection;

typedef NS_ENUM(NSInteger, SCUTCampus) {
    SCUTCampusNorth,
    SCUTCampusHEMC
};

typedef struct {
    BBTBusDirection direction;
    NSUInteger stationIndex;
    double percent;
} BBTBusViewPosition;

#endif
