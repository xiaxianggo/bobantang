//
//  BRSPlace.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 8/14/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

@import MapKit;
#import <Foundation/Foundation.h>

@interface BRSPlace : NSObject <MKAnnotation, NSCopying>

/* MKAnnotation Protocol */
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *subtitle;
@property (nonatomic)         CLLocationCoordinate2D coordinate;

/* center of this place (typically a building )*/
@property (nonatomic)         CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, strong) MKPolygon *boundaryPolygon;
@property (nonatomic)         NSString *type;
@property (nonatomic, strong) NSArray *subPlaces; // of NSString

- (id)initWithTitle:(NSString *)title Subtitle:(NSString *)subtitle coord:(CLLocationCoordinate2D) coord boudary:(MKPolygon *)boundary type:(NSString *)type subPlaces:(NSArray *)sub;
- (MKMapItem *)convertToMKMapItem;

+ (BRSPlace *)emptyPlaceWithCoordinate:(CLLocationCoordinate2D)coord;
@end
