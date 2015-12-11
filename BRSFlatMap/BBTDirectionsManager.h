//
//  BBTDirectionsManager.h
//  bobantang
//
//  Created by Xia Xiang on 9/11/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRSPlace.h"
#import <MapKit/MapKit.h>

NSString *const kBBTDirectionDidGetResponse;

@interface BBTDirectionsManager : NSObject

@property (strong, nonatomic) BRSPlace *sourcePlace;
@property (strong, nonatomic) BRSPlace *destnationPlace;

@property (strong, nonatomic) MKDirections *directions;
@property (strong, nonatomic) MKDirectionsResponse *directionResponse;

- (BOOL)readToDirect;
- (void)directionStart;
- (void)clearDirectionData;
- (BOOL)alreadyHaveDirections;

- (NSString *)distanceAndTravelTimeString;
@end
