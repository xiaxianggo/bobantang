//
//  BRSSCUTMapView.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/15/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

@protocol  BRSMapViewDelegate;
#import <MapKit/MapKit.h>



@interface BRSSCUTMapView : MKMapView

/* 
 the MKMapView doesn't support guestures, so add this guestureDelegate and guesture recognizers
 to add this feature
 */
@property (nonatomic, strong) id<BRSMapViewDelegate> gestureDelegate;

+ (MKCoordinateRegion)northCampusRegion;
+ (MKCoordinateRegion)HEMCCampusRegion;

- (id)initWithFrame:(CGRect)frame Campus:(SCUTCampus)campus;

- (void)switchToCampus:(SCUTCampus)campus;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(double)zoomLevel
                   animated:(BOOL)animated;

@end

@protocol BRSMapViewDelegate <NSObject>

- (void)mapView:(BRSSCUTMapView *)mapView LongPressingOnPoint:(CLLocationCoordinate2D)coord;
- (void)mapView:(BRSSCUTMapView *)mapView didSingleTapOnPoint:(CLLocationCoordinate2D)coord;

@end
