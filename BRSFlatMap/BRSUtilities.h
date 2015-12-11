//
//  BRSUtilities.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/18/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@interface BRSUtilities : NSObject

+ (void)BRSCoordiinateLog:(CLLocationCoordinate2D)coordinate;

+ (CLLocationCoordinate2D)locationCoordinateFromArray:(NSArray *)coordArray;
+ (MKPolygon *)polygonFromArray:(NSArray *)boundaryArray;
+ (MKPolyline *)polylineFromArray:(NSArray *)boundaryArray;
+ (CLLocationDistance)distanceFromCoord1:(CLLocationCoordinate2D)coord1 toCoord2:(CLLocationCoordinate2D)coord2;
@end
