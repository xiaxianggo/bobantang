//
//  BBT3DMapView.m
//  bobantang
//
//  Created by Xia Xiang on 8/31/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBT3DMapView.h"
#import "BBTTileSourceManager.h"

@interface BBT3DMapView() {
    RMMBTilesSource *_northCampusTile;
    RMMBTilesSource *_HEMCCampusTile;
}

@end

@implementation BBT3DMapView

- (instancetype)initWithFrame:(CGRect)frame northTilesource:(RMMBTilesSource *)northTilesource HEMCTilesource:(RMMBTilesSource *)HEMCTilesource
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _northCampusTile = northTilesource;
        _HEMCCampusTile = HEMCTilesource;
    }
    
    return self;
}

- (void)setupNorthCampusTilesource:(RMMBTilesSource *)tilesource
{
    _northCampusTile = tilesource;
}

- (void)setupHEMCCampusTilesource:(RMMBTilesSource *)tilesource
{
    _HEMCCampusTile = tilesource;
}

- (BOOL)hasCampusTileSource
{
    return _northCampusTile && _HEMCCampusTile;
}

- (void)displayHEMCCampusMap
{
    self.tileSource = _HEMCCampusTile;
    self.centerCoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
}

- (void)displayNorthCampusMap
{
    self.tileSource = _northCampusTile;
    self.centerCoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
}

- (void)removeAllTileSource;
{
    if (_northCampusTile) {
        [self removeTileSource:_northCampusTile];
    }
    if (_HEMCCampusTile) {
        [self removeTileSource:_HEMCCampusTile];
    }
}

-(void)zoomToFitAllAnnotationsAnimated:(BOOL)animated
{
    
    NSArray *annotations = self.annotations;
    
    if (annotations.count > 0) {
        
        CLLocationCoordinate2D firstCoordinate = [[annotations objectAtIndex:0]coordinate];
        
        //Find the southwest and northeast point
        double northEastLatitude = firstCoordinate.latitude;
        double northEastLongitude = firstCoordinate.longitude;
        double southWestLatitude = firstCoordinate.latitude;
        double southWestLongitude = firstCoordinate.longitude;
        
        for (RMAnnotation *aAnnotation in annotations) {
            CLLocationCoordinate2D coordinate = aAnnotation.coordinate;
            
            northEastLatitude = MAX(northEastLatitude, coordinate.latitude);
            northEastLongitude = MAX(northEastLongitude, coordinate.longitude);
            southWestLatitude = MIN(southWestLatitude, coordinate.latitude);
            southWestLongitude = MIN(southWestLongitude, coordinate.longitude);
            
            
        }
        //Define a margin so the corner annotations aren't flush to the edges
        double margin = 0.005;
        
        [self zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake(southWestLatitude-margin, southWestLongitude-margin)
                                             northEast:CLLocationCoordinate2DMake(northEastLatitude+margin, northEastLongitude+margin)
                                              animated:animated];
        
    }
}

@end
