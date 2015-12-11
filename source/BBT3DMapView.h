//
//  BBT3DMapView.h
//  bobantang
//
//  Created by Xia Xiang on 8/31/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import <Mapbox.h>
#import "RMMapView.h"

@interface BBT3DMapView : RMMapView

- (instancetype)initWithFrame:(CGRect)frame northTilesource:(RMMBTilesSource *)northTilesource HEMCTilesource:(RMMBTilesSource *)HEMCTilesource;
-(void)zoomToFitAllAnnotationsAnimated:(BOOL)animated;

- (void)displayNorthCampusMap;
- (void)displayHEMCCampusMap;

- (BOOL)hasCampusTileSource;
- (void)setupNorthCampusTilesource:(RMMBTilesSource *)tilesource;
- (void)setupHEMCCampusTilesource:(RMMBTilesSource *)tilesource;

@end
