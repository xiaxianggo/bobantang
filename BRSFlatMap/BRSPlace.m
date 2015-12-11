//
//  BRSPlace.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 8/14/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BRSPlace.h"

@implementation BRSPlace

- (id)initWithTitle:(NSString *)title Subtitle:(NSString *)subtitle coord:(CLLocationCoordinate2D)coord boudary:(MKPolygon *)boundary type:(NSString *)type subPlaces:(NSArray *)sub
{
    self = [super init];
    if (self) {
        self.title = title;
        self.subtitle = subtitle;
        self.centerCoordinate = coord;
        self.boundaryPolygon = boundary;
        self.type = type;
        self.subPlaces = sub;
        
        return self;
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    BRSPlace *copy = [[BRSPlace alloc] init];
    copy.title = [self.title copy];
    copy.subtitle = [self.subtitle copy];
    copy.coordinate = self.coordinate;
    
    copy.centerCoordinate = self.centerCoordinate;
    
    copy.boundaryPolygon = [MKPolygon polygonWithPoints:self.boundaryPolygon.points count:self.boundaryPolygon.pointCount];
    copy.type = self.type;
    copy.subPlaces = [self.subPlaces copy];
    return copy;
}

+ (BRSPlace *)emptyPlaceWithCoordinate:(CLLocationCoordinate2D)coord
{
    BRSPlace *place = [[BRSPlace alloc] init];
    place.coordinate = coord;
    place.title = @"";
    place.subtitle = @"";
    place.centerCoordinate = coord;
    place.boundaryPolygon = nil;
    place.subPlaces = nil;
    return place;
}

- (MKMapItem *)convertToMKMapItem
{
    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:self.centerCoordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    return mapItem;
}


@end
