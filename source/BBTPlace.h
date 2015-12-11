//
//  BBTPlace.h
//  bobantang
//
//  Created by Xia Xiang on 8/31/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
@import CoreLocation;
#import <Foundation/Foundation.h>

@interface BBTPlace : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *keywords;

- (instancetype)initWithCoord:(CLLocationCoordinate2D)coord title:(NSString *)title keywords:(NSArray *)keywords;
@end
