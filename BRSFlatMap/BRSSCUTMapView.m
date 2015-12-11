//
//  BRSSCUTMapView.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/15/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BRSSCUTMapView.h"

@interface BRSSCUTMapView()
@end


@implementation BRSSCUTMapView

+ (MKCoordinateRegion)northCampusRegion
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(23.158906, 113.346891);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01062, 0.0103);
    return MKCoordinateRegionMake(center, span);
}

// TODO : this region is not properly setted
+ (MKCoordinateRegion)HEMCCampusRegion
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(23.048657, 113.405471);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01062, 0.0103);
    return MKCoordinateRegionMake(center, span);
}

- (id)initWithFrame:(CGRect)frame Campus:(SCUTCampus)campus
{
    self = [super initWithFrame:frame];
    if (self) {
        [self switchToCampus:campus];
        [self addGestureRecognizers];
    }
    
        return self;
}

- (void)switchToCampus:(SCUTCampus)campus
{
    switch (campus) {
        case SCUTCampusHEMC:
            [self setRegion:[BRSSCUTMapView HEMCCampusRegion] animated:NO];
            break;
        case SCUTCampusNorth:
            [self setRegion:[BRSSCUTMapView northCampusRegion] animated:NO];
            break;
        default:
            break;
    }
}

- (void)addGestureRecognizers
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.33f;
    longPressGestureRecognizer.numberOfTouchesRequired = 1;
    longPressGestureRecognizer.allowableMovement = NO;
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    /*
     add this double tap gesture to prevent the double-tap-map-zoom gesture to be recognized as single tap.
     this is a ugly hack.
     */
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTapGuestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(handleSingleTap:)];
    singleTapGuestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGuestureRecognizer requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:singleTapGuestureRecognizer];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    CLLocationCoordinate2D touchMapCoordinate = [self convertPoint:touchPoint toCoordinateFromView:self];
    if ([self.gestureDelegate respondsToSelector:@selector(mapView:LongPressingOnPoint:)]) {
        [self.gestureDelegate mapView:self LongPressingOnPoint:touchMapCoordinate];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [sender locationInView:self];
        CLLocationCoordinate2D touchMapCoordinate = [self convertPoint:touchPoint toCoordinateFromView:self];
        if ([self.gestureDelegate respondsToSelector:@selector(mapView:didSingleTapOnPoint:)]) {
            [self.gestureDelegate mapView:self didSingleTapOnPoint:touchMapCoordinate];
        }
    }
}

// Do nothing while double tap, let the mapview to handle double tap zooming.
- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
}

#pragma mark -
#pragma mark Map conversion methods

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(double)zoomLevel
{
    NSLog(@"in custom zoomlevel-->%f",zoomLevel);
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    double zoomExponent = 20.0 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(double)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}


@end
