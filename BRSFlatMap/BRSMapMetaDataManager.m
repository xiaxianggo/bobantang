//
//  BRSMapMetaDataManager.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/15/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BRSUtilities.h"
#import "BRSMapMetaDataManager.h"
#import "MKPolygon+PointInPolygon.h"
#import "NSArray+BRSMostNearestElements.h"

@interface BRSMapMetaDataManager() {
    NSArray *_northCampusData;
    NSArray *_HEMCCampusData;
    
    MKPolygon *_northCampusBoundary;
    MKPolygon *_HEMCCampusBoundary;
    
    MKPolyline *_northCampusPolyline;
    MKPolyline *_HEMCCampusPolyline;
}
@property (nonatomic, strong, readwrite) NSArray *flatMapMetaData;
@end

@implementation BRSMapMetaDataManager

- (NSArray *)flatMapMetaData
{
    if ([BBTPreferences sharedInstance].northCampus) {
        return _northCampusData;
    } else {
        return _HEMCCampusData;
    }
}

- (MKPolygon *)campusBoundaryPolygon
{
    if ([BBTPreferences sharedInstance].northCampus) {
        return _northCampusBoundary;
    } else {
        return _HEMCCampusBoundary;
    }
}

-(id)init
{
    self = [super init];
    if (self) {
        [self loadFlatMapDataFromJSONFile];
        return self;
    }
    
    return nil;
}

static NSString *kJSONMapFeaturesKey = @"features";

- (void)loadFlatMapDataFromJSONFile
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SCUTFlatMapMetaData_n" ofType:@"geojson"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *flatMapData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    NSMutableArray *places = [[NSMutableArray alloc] init];
    for (NSDictionary *feature in flatMapData[kJSONMapFeaturesKey]) {
        CLLocationCoordinate2D center = [BRSUtilities locationCoordinateFromArray:feature[@"properties"][@"center"]];
        NSString *title = feature[@"properties"][@"name"];
        MKPolygon *boudary = [BRSUtilities polygonFromArray:feature[@"geometry"][@"coordinates"]];
        NSString *type = feature[@"properties"][@"type"];
        NSArray *subPLaces = feature[@"properties"][@"sub"];
        if (!subPLaces) {
            subPLaces = @[];
        }
        BRSPlace *place = [[BRSPlace alloc] initWithTitle:title Subtitle:nil coord:center boudary:boudary type:type subPlaces:subPLaces];
        place.coordinate = center;
        [places addObject:place];
    }
    _northCampusData = [places copy];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"SCUTFlatMapMetaData_s" ofType:@"geojson"];
    jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    flatMapData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    places = [[NSMutableArray alloc] init];
    for (NSDictionary *feature in flatMapData[kJSONMapFeaturesKey]) {
        CLLocationCoordinate2D center = [BRSUtilities locationCoordinateFromArray:feature[@"properties"][@"center"]];
        NSString *title = feature[@"properties"][@"name"];
        MKPolygon *boudary = [BRSUtilities polygonFromArray:feature[@"geometry"][@"coordinates"]];
        NSString *type = feature[@"properties"][@"type"];
        NSArray *subPLaces = feature[@"properties"][@"sub"];
        if (!subPLaces) {
            subPLaces = @[];
        }
        BRSPlace *place = [[BRSPlace alloc] initWithTitle:title Subtitle:nil coord:center boudary:boudary type:type subPlaces:subPLaces];
        place.coordinate = center;
        [places addObject:place];
    }
    _HEMCCampusData = [places copy];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"campusBoundary" ofType:@"geojson"];
    jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *boundaryDictionary = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    for (NSDictionary *feature in boundaryDictionary[kJSONMapFeaturesKey]) {
        if ([feature[@"properties"][@"name"] isEqualToString:@"South"]) {
            _HEMCCampusBoundary = [BRSUtilities polygonFromArray:feature[@"geometry"][@"coordinates"]];
            NSMutableArray *boundaryArray = [feature[@"geometry"][@"coordinates"] mutableCopy];
            [boundaryArray insertObject:boundaryArray.firstObject atIndex:[boundaryArray count]];
            _HEMCCampusPolyline = [BRSUtilities polylineFromArray:boundaryArray];
        } else if ([feature[@"properties"][@"name"] isEqualToString:@"North"]) {
            _northCampusBoundary = [BRSUtilities polygonFromArray:feature[@"geometry"][@"coordinates"]];
            NSMutableArray *boundaryArray = [feature[@"geometry"][@"coordinates"] mutableCopy];
            [boundaryArray insertObject:boundaryArray.firstObject atIndex:[boundaryArray count]];
            _northCampusPolyline = [BRSUtilities polylineFromArray:boundaryArray];
        }
    }
}

- (MKPolyline *)northCampusPolyline
{
    return _northCampusPolyline;
}

- (MKPolyline *)HEMCCampusPolyline
{
    return _HEMCCampusPolyline;
}

- (NSArray *)placesForCoordinate:(CLLocationCoordinate2D)coord maxCount:(NSUInteger)max
{
    NSMutableArray *result = [NSMutableArray array];
    for (BRSPlace *place in self.flatMapMetaData) {         // the coord is in one of the places
        if ([place.boundaryPolygon coordInPolygon:coord]) {
            [result addObject:place];
            break;
        }
    }
    if ([result count] == 0) {                              // if the coord is not in one fo the places, find the surrounding places
        result = [[self.flatMapMetaData most:max NearstElements:^ NSComparisonResult (BRSPlace *currentPlace, BRSPlace *resultPlace){
            CLLocationDistance currentDistance = [BRSUtilities distanceFromCoord1:currentPlace.centerCoordinate toCoord2:coord];
            CLLocationDistance resultDistance = [BRSUtilities distanceFromCoord1:resultPlace.centerCoordinate toCoord2:coord];
            return currentDistance < resultDistance ? NSOrderedAscending : NSOrderedDescending;
        }] copy];
    }
    return [result copy];
}

@end
