//
//  MKPolygon+PointInPolygon.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 8/14/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolygon (PointInPolygon)
-(BOOL)coordInPolygon:(CLLocationCoordinate2D)coord;
-(BOOL)pointInPolygon:(MKMapPoint)point;
@end
