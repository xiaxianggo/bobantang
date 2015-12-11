//
//  MKPolyline+BBTExt.h
//  bobantang
//
//  Created by Bill Bai on 9/26/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (BBTExt)

+ (MKPolygon *)polylineFromArray:(NSArray *)boundaryArray;

@end
