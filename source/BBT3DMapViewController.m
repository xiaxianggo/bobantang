//
//  BBT3DMapViewController.m
//  bobantang
//
//  Created by Xia Xiang on 8/30/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import <Mapbox.h>
#import "BBT3DMapView.h"
#import "BBT3DMapViewController.h"
#import "BBT3DMapMetaDataManager.h"
#import "BBTPlace.h"
#import "BBTTileSourceManager.h"

@interface BBT3DMapViewController() <RMMapViewDelegate>
@property (strong, nonatomic) BBT3DMapView *mapView;
@property (strong, nonatomic) BBT3DMapMetaDataManager *dataManager;
@property (strong, nonatomic) UISearchDisplayController *containerSearchDC;
@end


@implementation BBT3DMapViewController

- (BBT3DMapView *)mapView
{
    UITableView
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if (!_mapView) {
        if ([BBTTileSourceManager northCampusTile] && [BBTTileSourceManager HEMCCampusTile]) {
            _mapView = [[BBT3DMapView alloc] initWithFrame:appFrame
                                          northTilesource:[BBTTileSourceManager northCampusTile]
                                           HEMCTilesource:[BBTTileSourceManager HEMCCampusTile]];
        } else {
            _mapView = [[BBT3DMapView alloc] initWithFrame:appFrame];
        }
        _mapView.hideAttribution = YES;
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.adjustTilesForRetinaDisplay = YES;
        _mapView.showLogoBug = NO;
    }
    return _mapView;
}
- (void)loadView
{
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = ({
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        view;
    });

    [self.view addSubview:self.mapView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([BBTPreferences sharedInstance].northCampus) {
        [self.mapView displayNorthCampusMap];
    } else {
        [self.mapView displayHEMCCampusMap];
    }
    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:RMUserTrackingModeNone];
    self.dataManager = [[BBT3DMapMetaDataManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([BBTTileSourceManager hasDownloadTilesource]) {
        if (![self.mapView hasCampusTileSource]) {
            [self.mapView setupHEMCCampusTilesource:[BBTTileSourceManager HEMCCampusTile]];
            [self.mapView setupNorthCampusTilesource:[BBTTileSourceManager northCampusTile]];
        }
        self.parentViewController.navigationItem.rightBarButtonItem = nil;
        self.parentViewController.navigationItem.leftBarButtonItem = nil;
        if ([BBTPreferences sharedInstance].northCampus) {
            [self.mapView displayNorthCampusMap];
        } else {
            [self.mapView displayHEMCCampusMap];
        }
    } else { //fall back to flat map
        NSLog(@"fall back");
        [self.mapContainerVC fallbackToFlatMap];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)changeMapCampusRegion
{
    [self.mapView removeAllAnnotations];
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    preferences.northCampus = preferences.northCampus ? NO : YES;
    if ([BBTPreferences sharedInstance].northCampus) {
        [self.mapView displayNorthCampusMap];
    } else {
        [self.mapView displayHEMCCampusMap];
    }
}

#pragma mark - RMMapview delegate

- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point
{
    [self.mapView removeAllAnnotations];
}

- (void)longPressOnMap:(RMMapView *)map at:(CGPoint)point
{
    [self.mapView removeAllAnnotations];
    
    RMMBTilesSource *source = (RMMBTilesSource *)map.tileSource;
    if ([source conformsToProtocol:@protocol(RMInteractiveSource)] && [source supportsInteractivity])
    {
        NSString *formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeTeaser
                                                         forPoint:point
                                                        inMapView:map];
        if (formattedOutput && [formattedOutput length])
        {
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:map
                                                                coordinate:[map pixelToCoordinate:point]
                                                                  andTitle:formattedOutput];
            [map addAnnotation:annotation];
            [self.mapView selectAnnotation:annotation animated:YES];

        }
    }
}

- (void)mapView:(RMMapView *)mapView didDeselectAnnotation:(RMAnnotation *)annotation
{
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if ([annotation isUserLocationAnnotation]) {
        return nil;
    }
    
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"star"
                                                         tintColor:[UIColor colorWithRed:177.0f/255.0f green:125.0f/255.0f blue:245.0f/255.0f alpha:0.76]];
    marker.canShowCallout = YES;
    
    return marker;
}

//- (void)mapView:(RMMapView *)mapView didDeselectAnnotation:(RMAnnotation *)annotation
//{
//    [mapView selectAnnotation:annotation animated:NO];
//    //NSLog(@"di deselect annotation");
//}

// override
- (void)setContainerSearchDisplayController:(UISearchDisplayController *)searchDisplayController containVC:(BBTMapContainerVC *)mapContainerVC
{
    self.containerSearchDC = searchDisplayController;
}

#pragma mark - UITable View delegate (table view for search display)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BBTPlace *place = [self.dataManager.searchResult objectAtIndex:indexPath.row];
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:place.coordinates andTitle:place.title];
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    [self.mapView zoomToFitAllAnnotationsAnimated:YES];
    [self.containerSearchDC setActive:NO animated:YES];
}

#pragma mark - UITable View Datasource (table view for search display)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataManager.searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resultCell"];
    BBTPlace *place = self.dataManager.searchResult[indexPath.row];
    cell.textLabel.text = place.title;
    return cell;
}


#pragma mark - UISearch Display Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.dataManager updateSearchResultForKeyword:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

#pragma mark - UISearch Bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search button clicked");
//    [self.mapView removeAllAnnotations];
//    [self.dataManager updateSearchResultForKeyword:searchBar.text];
//    [self.containerSearchDC setActive:NO animated:YES];
//    [self displayAllSearchResultAnnotation];
//    [self.mapView zoomToFitAllAnnotationsAnimated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"should begin ?");
    NSLog(@"%@",self.containerSearchDC);
    [self.containerSearchDC setActive:YES animated:YES];
    return YES;
}

@end
