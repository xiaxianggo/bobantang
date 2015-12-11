//
//  MKPolyline+BBTExt.m
//  bobantang
//
//  Created by Bill Bai on 9/26/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import "MKPolyline+BBTExt.h"

@implementation MKPolyline (BBTExt)

+ (MKPolygon *)polylineFromArray:(NSArray *)boundaryArray;
{
    NSUInteger count = boundaryArray.count;
    CLLocationCoordinate2D coords[count];
    for (NSInteger i = 0; i < count; i++) {
        coords[i] = [BRSUtilities locationCoordinateFromArray:boundaryArray[i]];
    }
    
    return [MKPolygon polygonWithCoordinates:coords count:count];
}

@end
