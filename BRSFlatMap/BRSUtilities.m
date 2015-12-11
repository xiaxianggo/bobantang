//
//  BRSUtilities.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/18/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BRSUtilities.h"

@implementation BRSUtilities

+ (void)BRSCoordiinateLog:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"Coord=> latitude %f, longitude %f", coordinate.latitude, coordinate.longitude);
}

+ (CLLocationCoordinate2D)locationCoordinateFromArray:(NSArray *)coordArray
{
    CLLocationDegrees lat = [(NSNumber *)coordArray[1] doubleValue];
    CLLocationDegrees lon = [(NSNumber *)coordArray[0] doubleValue];
    return CLLocationCoordinate2DMake(lat, lon);
}

+ (MKPolygon *)polygonFromArray:(NSArray *)boundaryArray
{
    NSUInteger count = boundaryArray.count;
    CLLocationCoordinate2D coords[count];
    for (NSInteger i = 0; i < count; i++) {
        coords[i] = [BRSUtilities locationCoordinateFromArray:boundaryArray[i]];
    }
    
    return [MKPolygon polygonWithCoordinates:coords count:count];
}

+ (MKPolyline *)polylineFromArray:(NSArray *)boundaryArray
{
    NSUInteger count = boundaryArray.count;
    CLLocationCoordinate2D coords[count];
    for (NSInteger i = 0; i < count; i++) {
        coords[i] = [BRSUtilities locationCoordinateFromArray:boundaryArray[i]];
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:count];
}

+ (CLLocationDistance)distanceFromCoord1:(CLLocationCoordinate2D)coord1 toCoord2:(CLLocationCoordinate2D)coord2
{
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:coord1.latitude longitude:coord1.longitude];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:coord2.latitude longitude:coord2.longitude];
    
    return [location1 distanceFromLocation:location2];
}


@end
