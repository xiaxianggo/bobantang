//
//  BBT3DMapManager.m
//  bobantang
//
//  Created by Xia Xiang on 8/30/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BBT3DMapMetaDataManager.h"
#import "BBTPlace.h"
@interface BBT3DMapMetaDataManager() {
    NSArray *_northCampusMetaData;  //of BBTPlace
    NSArray *_southCampusMetaData;  //of BBTPlace
}
@property (strong, nonatomic, readwrite) NSArray *metaData; //of BBTPlace
@property (strong, nonatomic, readwrite) NSMutableArray *searchResult; //of BBTPlace
@end

@implementation BBT3DMapMetaDataManager

- (NSArray *)metaData
{
    if ([BBTPreferences sharedInstance].northCampus) {
        return _northCampusMetaData;
    } else {
        return _southCampusMetaData;
    }
}

- (NSMutableArray *)searchResult
{
    if (!_searchResult) {
        _searchResult = [NSMutableArray array];
    }
    return _searchResult;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *geojsonURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"3dMapMetaData_n" ofType:@"geojson"]];
        NSString *geojsonString = [NSString stringWithContentsOfURL:geojsonURL encoding:NSUTF8StringEncoding error:Nil];
        NSDictionary *geojsonData = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[geojsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSArray *features = (NSArray *)(geojsonData[@"features"]);
        NSMutableArray *metaDataArray = [NSMutableArray array];
        for (NSDictionary *feature in features) {
            CLLocationDegrees lat = [(NSNumber *)(feature[@"geometry"][@"coordinates"][1]) doubleValue];
            CLLocationDegrees lon = [(NSNumber *)(feature[@"geometry"][@"coordinates"][0]) doubleValue];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
            BBTPlace *place = [[BBTPlace alloc] initWithCoord:coord
                                                        title:feature[@"properties"][@"title"]
                                                     keywords:feature[@"properties"][@"keywords"]];
            [metaDataArray addObject:place];
        }
        _northCampusMetaData = [metaDataArray copy];
        
        geojsonURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"3dMapMetaData_s" ofType:@"geojson"]];
        geojsonString = [NSString stringWithContentsOfURL:geojsonURL encoding:NSUTF8StringEncoding error:Nil];
        geojsonData = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[geojsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        features = (NSArray *)(geojsonData[@"features"]);
        [metaDataArray removeAllObjects];
        for (NSDictionary *feature in features) {
            CLLocationDegrees lat = [(NSNumber *)(feature[@"geometry"][@"coordinates"][1]) doubleValue];
            CLLocationDegrees lon = [(NSNumber *)(feature[@"geometry"][@"coordinates"][0]) doubleValue];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
            BBTPlace *place = [[BBTPlace alloc] initWithCoord:coord
                                                        title:feature[@"properties"][@"title"]
                                                     keywords:feature[@"properties"][@"keywords"]];
            [metaDataArray addObject:place];
        }
        _southCampusMetaData = [metaDataArray copy];
    }
    
    return self;
}

#pragma mark - search method

- (void)updateSearchResultForKeyword:(NSString *) keyword
{
    [self.searchResult removeAllObjects];
    
    for (BBTPlace *place in self.metaData) {
        NSRange range;
        for (NSString *key in place.keywords) {
            range = [key rangeOfString:keyword options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [self.searchResult addObject:place];
                break;
            }
        }
    }
}

@end
