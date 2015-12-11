//
//  BRSMapCoordinateTester.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/18/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@interface BRSMapCoordinateTester : NSObject

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *testdata;


- (id)initWithMapView:(MKMapView *)mapview;

- (void)addAllPolygonsAndAnnotationsToMap;
- (NSArray *)centerAnnotations;
- (NSArray *)buildingPolygons;

@end
