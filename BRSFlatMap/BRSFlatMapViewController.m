//
//  BRSFlatMapViewController.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/15/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import <CRToast/CRToast.h>
#import <WSCoachMarksView/WSCoachMarksView.h>
#import <CCHMapClusterController/CCHMapClusterController.h>
#import <CCHMapClusterController/CCHMapClusterControllerDelegate.h>
#import <CCHMapClusterController/CCHMapClusterAnnotation.h>


#import "MKPolygon+PointInPolygon.h"
#import "NSArray+BRSMostNearestElements.h"
#import "BRSMapSearchHelper.h"
#import "BRSPlace.h"
#import "BRSUtilities.h"
#import "BRSMapSearchHelper.h"

#import "BRSTostVCTransAnimator.h"

#import "BRSPlaceViewController.h"

#import "BRSDirectionViewController.h"
#import "BBTDirectionsManager.h"

#import "UIButton+ASANUserTrackingButton.h"


#import "BRSFlatMapViewController.h"
/////////////tester///////////////
#import "BRSMapCoordinateTester.h"
/////////////////////////////////

@import CoreLocation;

@interface BRSFlatMapViewController() <CLLocationManagerDelegate, CCHMapClusterControllerDelegate, BRSMapSearchDelegate, BRSTPlaceVCdelegate, UIViewControllerTransitioningDelegate, BRSDirectionViewControllerDelegate>

@property (nonatomic) BOOL shouldResetCampusRegion;

@property (nonatomic, weak) BBTMapContainerVC *containerVC;

/* Annotation Cluster*/
@property (nonatomic, strong) CCHMapClusterController *mapClusterController;
@property (nonatomic, strong) BRSMapCoordinateTester *coordTester;

/* serach */
@property (nonatomic, strong) BRSMapSearchHelper *searchHelper;

/* Map Property */
@property (nonatomic, strong) BRSPlace *currentAnnotation;
@property (nonatomic, strong) BRSPlace *highlightedPlace;


@property (nonatomic) CGFloat popupViewControllerHeight;
/* place View controller */
@property (nonatomic, strong) BRSPlaceViewController *placeViewController;
@property (nonatomic) BOOL placeVCShowed;
@property (nonatomic) NSUInteger failedLongPressCount;

/* directions */
@property (nonatomic, strong) BBTDirectionsManager *directionManager;
@property (nonatomic, strong) BRSDirectionViewController *directionVC;
@property (nonatomic) BOOL directionVCShowed;
@property (nonatomic, strong) BRSPlace *startAnnotation;
@property (nonatomic, strong) BRSPlace *endAnnotation;
@property (nonatomic, strong) MKPolyline *routeOverlay;
@property (nonatomic, strong) UIBarButtonItem *routeButton;

/* user tracking*/
@property (nonatomic, strong) UIButton *userTrackingButton;
@property (nonatomic, strong) UIImage *trackingImage;
@property (nonatomic, strong) UIImage *trackingImageHighlighted;
@property (nonatomic, strong) CLLocationManager *locationManager;

/* the container's UISearchDisplatController */
@property (nonatomic, weak) UISearchDisplayController *containerSearchDC;

/* data model*/
@property (nonatomic, strong) BRSMapMetaDataManager *dataManager;

@end


@implementation BRSFlatMapViewController

- (BRSPlaceViewController *)placeViewController
{
    if (!_placeViewController) {
        _placeViewController = [[BRSPlaceViewController alloc] init];
        _placeViewController.transitioningDelegate = self;
        _placeViewController.delegate = self;
        _placeViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return _placeViewController;
}

- (BRSMapMetaDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[BRSMapMetaDataManager alloc] init];
    }
    return _dataManager;
}

- (BRSMapSearchHelper *)searchHelper
{
    if (!_searchHelper) {
        _searchHelper = [[BRSMapSearchHelper alloc] init];
        _searchHelper.delegate = self;
    }
    return _searchHelper;
}

- (BBTDirectionsManager *)directionManager
{
    if (!_directionManager) {
        _directionManager = [[BBTDirectionsManager alloc] init];
    }
    return _directionManager;
}

-(BRSSCUTMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[BRSSCUTMapView alloc] initWithFrame:self.view.frame Campus:SCUTCampusNorth];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsBuildings = NO;
    }
    return _mapView;
}

- (void)loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    self.view = ({
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        view.opaque = YES;
        view;
    });
    
    [self.view addSubview:self.mapView];
    
    self.trackingImage = [UIImage imageNamed:@"position"];
    self.trackingImageHighlighted = [UIImage imageNamed:@"positionHighLighted"];

    self.userTrackingButton = [UIButton ASANRoundRectButtonWithFrame:CGRectMake(10.0f, appFrame.size.height - 110.0f, 46.0f, 46.0f) image:self.trackingImage];
    [self.view addSubview:self.userTrackingButton];
    [self.userTrackingButton addTarget:self action:@selector(trackingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* config the mapView */
    self.mapView.delegate = self;
    self.mapView.gestureDelegate = self;
    self.mapView.showsBuildings = YES;
    
    self.failedLongPressCount = 0;
    
    [self.mapView addOverlay:[self.dataManager northCampusPolyline]];
    [self.mapView addOverlay:[self.dataManager HEMCCampusPolyline]];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    [self.mapView setShowsUserLocation:NO];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    
    self.placeVCShowed = NO;
    self.directionVCShowed = NO;
    self.shouldResetCampusRegion = YES;

    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
//    [self.mapClusterController addAnnotations:[self.coordTester centerAnnotations] withCompletionHandler:nil];
    
    // first time using flat map
    if (![BBTPreferences sharedInstance].hasSeenFlatMapHelp) {
        CGRect centerRect = CGRectMake(self.view.center.x, self.view.center.y, 42, 42);
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect)centerRect],
                                    @"caption": @"在校区内长按地图显示详细信息"
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect)self.containerVC.buttonGroupRect],
                                    @"caption": @"切换2D/2.5D地图\n\n切换南北校区\n\n地图复位"
                                    }
                                ];
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        [self.view addSubview:coachMarksView];
        [coachMarksView start];
        [BBTPreferences sharedInstance].hasSeenFlatMapHelp = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetDirectionsResponse:)
                                                 name:kBBTDirectionDidGetResponse
                                               object:self.directionManager];
    
    self.routeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"routeBefore"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(toogleDirection)];
    self.parentViewController.navigationItem.rightBarButtonItem = self.routeButton;
    
    if (![self.view.subviews containsObject:self.mapView]) {
        [self.view addSubview:self.mapView];
    }
    
    if (self.shouldResetCampusRegion) {
        if ([BBTPreferences sharedInstance].northCampus) {
            [self.mapView switchToCampus:SCUTCampusNorth];
        } else {
            [self.mapView switchToCampus:SCUTCampusHEMC];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.shouldResetCampusRegion = YES;
    [self cleanUpMap];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"flat map disappeared");
}


- (void)trackingButtonTapped:(UIButton *)sender
{
    if ([sender currentImage] == self.trackingImage) {
        [sender setImage:self.trackingImageHighlighted forState:UIControlStateNormal];
        self.mapView.showsUserLocation = YES;
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    } else {
        [sender setImage:self.trackingImage forState:UIControlStateNormal];
        self.mapView.showsUserLocation = NO;
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}

- (void)toogleDirection
{
    if (self.placeVCShowed) {
        NSLog(@"place vc showing");
        [self.placeViewController dismissViewControllerAnimated:YES completion:^(void) {
            self.placeVCShowed = NO;
            [self toogleDirectionViewController];
        }];
    } else {
        NSLog(@"place vc not showing");
        [self toogleDirectionViewController];
    }
    
}

- (void)toogleDirectionViewController
{
    NSLog(@"toogle direction!");
    if (!self.directionVCShowed) {
        [self.routeButton setImage:[UIImage imageNamed:@"routeAfter"]];
        if ([self.directionManager alreadyHaveDirections]) {
            [self drawDirectionsOverlay];
        }
        self.directionVC = [[BRSDirectionViewController alloc] initWithDataManager:self.dataManager
                                                                  directionManager:self.directionManager];
        self.directionVC.transitioningDelegate = self;
        self.directionVC.modalPresentationStyle = UIModalPresentationCustom;
        self.directionVC.delegate = self;
        [self presentViewController:self.directionVC animated:YES completion:^{
            self.directionVCShowed = YES;
        }];
    } else {
        [self.routeButton setImage:[UIImage imageNamed:@"routeBefore"]];
        if (self.directionManager.directions.isCalculating) {
            [self.directionManager.directions cancel];
        }
        [self.directionVC dismissViewControllerAnimated:YES completion:^{
            self.directionVCShowed = NO;
            [self removeDirectionsOverlay];
        }];
    }
}

- (void)didGetDirectionsResponse:(NSNotification *)notification
{
    if ([notification.userInfo[@"hasErr"] boolValue]) {
        if (self.directionManager.directions.isCalculating) {
            [self.directionManager.directions cancel];
        }
        [self.directionVC dismissViewControllerAnimated:YES completion:^{
            self.directionVCShowed = NO;
            [self.routeButton setImage:[UIImage imageNamed:@"routeBefore"]];
            [self removeDirectionsOverlay];
            NSError *error = notification.userInfo[@"error"];
            NSString *errorDescription = error.localizedDescription;
            NSLog(@"%@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取路线失败" message:errorDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
        }];
    } else {
        NSLog(@"get direction respose");
        [self drawDirectionsOverlay];
    }
}

- (void)drawDirectionsOverlay
{
    if (self.routeOverlay) {
        [self.mapView removeOverlay:self.routeOverlay];
    }
    [self deHightlightPlace];
    MKRoute *route = self.directionManager.directionResponse.routes.firstObject;
    self.routeOverlay = route.polyline;
    self.startAnnotation = self.directionManager.sourcePlace;
    self.endAnnotation = self.directionManager.destnationPlace;
    [self.mapView addOverlay:self.routeOverlay];
    [self.mapView addAnnotations:@[self.startAnnotation, self.endAnnotation]];
    [self fitMapViewForPolyline:self.routeOverlay];
    [self.mapView setUserInteractionEnabled:NO];
}

- (void)removeDirectionsOverlay
{
    if (self.routeOverlay) {
        [self.mapView removeOverlay:self.routeOverlay];
    }
    if (self.startAnnotation) {
        [self.mapView removeAnnotation:self.startAnnotation];
    }
    if (self.endAnnotation) {
        [self.mapView removeAnnotation:self.endAnnotation];
    }
    [self.mapView setUserInteractionEnabled:YES];
}

#pragma mark - CCHMapClusterControlerDelegate

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    return nil;
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = MIN(mapClusterAnnotation.annotations.count, 5);
    NSArray *annotations = [mapClusterAnnotation.annotations.allObjects subarrayWithRange:NSMakeRange(0, numAnnotations)];
    NSArray *titles = [annotations valueForKey:@"title"];
    return [titles firstObject];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
	MKPinAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[BRSPlace class]])
	{
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil)
		{
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            if (annotation == self.startAnnotation) {
                annotationView.pinColor = MKPinAnnotationColorGreen;
            } else if (annotation == self.endAnnotation) {
                annotationView.pinColor = MKPinAnnotationColorPurple;
            } else {
                annotationView.pinColor = MKPinAnnotationColorRed;
            }
            //annotationView.canShowCallout = YES;
			//annotationView.animatesDrop = YES;
		}
    }
    
	return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
	{
		MKPolygonRenderer *render = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
		render.fillColor = [UIColor orangeColor];
        //render.strokeColor = [UIColor grayColor];
        //render.lineWidth = 3.0;
        render.alpha = 0.4;
        return render;
	} else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        if (overlay == [self.dataManager northCampusPolyline] || overlay == [self.dataManager HEMCCampusPolyline]) {
            render.strokeColor = [UIColor grayColor];
            render.lineDashPhase = 10;
            NSArray* array = @[@(7), @(6)];
            render.lineDashPattern = array;
            render.lineWidth = 1.0f;
        } else {
            render.strokeColor = [UIColor blueColor];
            render.lineWidth = 4.0f;
        }
        return render;
    }
	return nil;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self.userTrackingButton setImage:self.trackingImage forState:UIControlStateNormal];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [self.userTrackingButton setImage:self.trackingImage forState:UIControlStateNormal];
    }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    [self.userTrackingButton setImage:self.trackingImage forState:UIControlStateNormal];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    BRSPlace *annotationPlace = (BRSPlace *)view.annotation;
    [self showDetailForCoordinate:annotationPlace.coordinate];
    NSLog(@"%@",annotationPlace.title);
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //NSLog(@"now zoom level---> %f", [self getZoomLevel]);
}

#pragma mark - BRSMapViewDelegate

- (void)mapView:(BRSSCUTMapView *)mapView LongPressingOnPoint:(CLLocationCoordinate2D)coord
{
    if ([self.dataManager.campusBoundaryPolygon coordInPolygon:coord]) {
        NSLog(@"long pressing within campus boundary");
        [BRSUtilities BRSCoordiinateLog:coord];
        
        [self setAndShowCurrentAnnotation:[BRSPlace emptyPlaceWithCoordinate:coord]];
        NSArray *placesForCoord = [self.dataManager placesForCoordinate:coord maxCount:4];
        [self showDetailForPlaces:placesForCoord];

    } else {
        NSLog(@"long pressing out of campus boundary");
        if (self.failedLongPressCount == 0 || self.failedLongPressCount == 7 || self.failedLongPressCount == 76) {
            NSDictionary *options;
            if (self.failedLongPressCount == 0) {
                options = @{
                            kCRToastTextKey :@"在校区外的点击是不会有结果的哦~ :)",
                            kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                            kCRToastBackgroundColorKey : [UIColor BBTSusscessfulGreen],
                            kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                            kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                            };
            } else if (self.failedLongPressCount == 7) {
                options = @{
                            kCRToastTextKey :@"真的是不会有结果的哦~ :)",
                            kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                            kCRToastBackgroundColorKey : [UIColor BBTSusscessfulGreen],
                            kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                            kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                            };
            } else if (self.failedLongPressCount == 76) {
                options = @{
                            kCRToastTextKey :@"2333333333333333 :) 别试了",
                            kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                            kCRToastBackgroundColorKey : [UIColor BBTSusscessfulGreen],
                            kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                            kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                            };
            }
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                            NSLog(@"Completed");
                                        }];
        } else {
            
        }
        
        self.failedLongPressCount += 1;
    }
}

- (void)mapView:(BRSSCUTMapView *)mapView didSingleTapOnPoint:(CLLocationCoordinate2D)coord
{
    NSLog(@"did single tap");
    [self hidePlaceViewController];
}



#pragma mark - BRSMapSearchDelegate

- (void)mapSearchController:(BRSMapSearchHelper *)searchHelper didGetSearchResponse:(MKLocalSearchResponse *)response
{
}

- (NSArray *)mapDataForSearchHelper:(BRSMapSearchHelper *)searchHelper
{
    return self.dataManager.flatMapMetaData;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self removeCurrentAnnotation];
    BRSPlace *place = (BRSPlace *)self.searchHelper.saerchResult[indexPath.row];
    [self setAndShowCurrentAnnotation:place];
    [self showDetailForPlaces:@[place]];
    [self.containerSearchDC setActive:NO];
}

#pragma mark - UITAbleViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchHelper.saerchResult count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BRSSearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    BRSPlace *place = (BRSPlace *)self.searchHelper.saerchResult[indexPath.row];
    cell.textLabel.text = place.title;
    cell.detailTextLabel.text = place.type;
    return cell;
}


#pragma mark - UISearchDisplayControllerDelegate


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchHelper updateSearchResultForKeyword:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"wii begin");
    [self.parentViewController.navigationItem setRightBarButtonItem:nil animated:YES];
    self.containerSearchDC.searchBar.showsCancelButton = YES;
    //NSLog(@"%@", controller.searchBar.delegate);
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.parentViewController.navigationItem setRightBarButtonItem:self.routeButton animated:YES];
    self.containerSearchDC.searchBar.showsCancelButton = NO;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (self.directionVCShowed) {
        [self.directionVC dismissViewControllerAnimated:YES completion:^ {
            self.directionVCShowed = NO;
            [searchBar becomeFirstResponder];
        }];
    }
    
    if (self.placeVCShowed) {
        [self.placeViewController dismissViewControllerAnimated:YES completion:^ {
            self.placeVCShowed = NO;
            [self.containerSearchDC setActive:YES animated:YES];
            [searchBar becomeFirstResponder];
        }];
    }
    [self.containerSearchDC setActive:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self removeCurrentAnnotation];
    if ([self.searchHelper.saerchResult count] > 0) {
        BRSPlace *place = (BRSPlace *)[self.searchHelper.saerchResult firstObject];
        [self setAndShowCurrentAnnotation:place];
        [self showDetailForPlaces:@[place]];
        [self.containerSearchDC setActive:NO];
    }
    
}

#pragma mark - BRSPlaceViewController Delegate
- (void)placeVC:(BRSPlaceViewController *)placeVC didEnterMode:(BOOL)mode //YES for big mode, NO for small mode
{
    if (mode) {
        NSLog(@"place VC did enter big mode");
    } else {
        NSLog(@"place VC did enter small mode");
    }
    self.popupViewControllerHeight = self.view.frame.size.height - placeVC.view.frame.origin.y;
}

- (void)didDismissPlaceVC:(BRSPlaceViewController *)placeVC
{
    NSLog(@"place VC did dismiss");
    self.shouldResetCampusRegion = YES;
    self.placeVCShowed = NO;
    self.popupViewControllerHeight = 0;
    [self deHightlightPlace];
}

- (void)didPresentPlaceVC:(BRSPlaceViewController *)placeVC
{
    NSLog(@"place VC did present");
    self.placeVCShowed = YES;
    self.popupViewControllerHeight = self.view.frame.size.height - placeVC.view.frame.origin.y;
}

- (void)placeVC:(BRSPlaceViewController *)placeVC didSelectPlace:(BRSPlace *)place
{
    [self hightlightPlace:place];
}

- (void)placeVC:(BRSPlaceViewController *)placeVC needDirectionsFrom:(BRSPlace *)sourcePlace
{
    [self.directionManager clearDirectionData];
    self.directionManager.sourcePlace = sourcePlace;
    if (self.placeVCShowed) {
        [self.placeViewController dismissViewControllerAnimated:YES completion:^ {
            self.placeVCShowed = NO;
            [self toogleDirection];
        }];
    } else {
        [self toogleDirection];
    }
}

- (void)placeVC:(BRSPlaceViewController *)placeVC needDirectionsTo:(BRSPlace *)destnationPlace
{
    [self.directionManager clearDirectionData];
    self.directionManager.destnationPlace = destnationPlace;
    if (self.placeVCShowed) {
        [self.placeViewController dismissViewControllerAnimated:YES completion:^ {
            self.placeVCShowed = NO;
            [self toogleDirection];
        }];
    } else {
        [self toogleDirection];
    }}

#pragma mark - BRSDirectionViewControllerDelegate

- (void)directionVC:(BRSDirectionViewController *)vc didGetDirectionResponse:(MKDirectionsResponse *)response
{}

- (void)directionVCdidEnterBigMode:(BRSDirectionViewController *)vc
{
    NSLog(@"direction VC did enter big mode");
    self.popupViewControllerHeight = self.view.frame.size.height - vc.view.frame.origin.y;

}

-(void)directionVCdidEnterSmallMode:(BRSDirectionViewController *)vc
{
    NSLog(@"direction VC did enter small mode");
    self.popupViewControllerHeight = self.view.frame.size.height - vc.view.frame.origin.y;
}

- (void)directionVCDidPresent:(BRSDirectionViewController *)vc
{
    NSLog(@"direction VC did present");
    self.directionVCShowed = YES;
    self.popupViewControllerHeight = self.view.frame.size.height - vc.view.frame.origin.y;
}

- (void)directionVCDidDismiss:(BRSDirectionViewController *)vc
{
    NSLog(@"direction VC did dismiss");
    if (self.directionManager.directions.isCalculating) {
        [self.directionManager.directions cancel];
    }
    self.shouldResetCampusRegion = YES;
    self.directionVCShowed = NO;
    [self removeDirectionsOverlay];
    [self.routeButton setImage:[UIImage imageNamed:@"routeBefore"]];
    self.popupViewControllerHeight = 0;

}

#pragma mark - Map Utlities

- (void)showDetailForPlaces:(NSArray *)places
{
    if (self.directionVCShowed) {
        [self.directionVC dismissViewControllerAnimated:YES completion:^{
            self.directionVCShowed = NO;
        }];
    }
    if ([places count] == 1) {
        [self hightlightPlace:places.firstObject];
    } else {
        [self deHightlightPlace];
    }
    
    if (self.placeVCShowed) {
        self.placeViewController.places = places;
    } else {
        self.placeViewController.places = places;
        [self presentViewController:self.placeViewController animated:YES completion:^ {
            self.placeVCShowed = YES;
        }];
    }
    
}

- (void)hidePlaceViewController
{
    if (self.placeVCShowed) {
        [self.placeViewController dismissViewControllerAnimated:YES completion:^(void) {
            self.placeVCShowed = NO;
            [self deHightlightPlace];
        }];
    }
}

- (void)showDetailForCoordinate:(CLLocationCoordinate2D)coord
{
    // Search places for point
    // Show place view controller
    if (self.directionVCShowed) {
        [self toogleDirection];
    }
    if (!self.placeVCShowed) {
        NSArray *result = [self.dataManager placesForCoordinate:coord maxCount:4];
        [self showDetailForPlaces:result];
    }
}

- (void)hightlightPlace:(BRSPlace *)place
{
    [self deHightlightPlace];
    self.highlightedPlace = place;
    [self.mapView addOverlay:place.boundaryPolygon];
    [self fitMapViewForPolygon:place.boundaryPolygon];
}

- (void)deHightlightPlace
{
    if (self.highlightedPlace) {
        [self.mapView removeOverlay:self.highlightedPlace.boundaryPolygon];
    }
}

- (void)setAndShowCurrentAnnotation:(BRSPlace *)placeAnnotation
{
    if (self.currentAnnotation) {
        [self.mapView removeAnnotation:self.currentAnnotation];
    }
    self.currentAnnotation = placeAnnotation;
    [self.mapView addAnnotation:placeAnnotation];
    //[self zoomToFitMapAnnotations];
}

- (void)removeCurrentAnnotation
{
    if (self.currentAnnotation) {
        [self.mapView removeAnnotation:self.currentAnnotation];
        self.currentAnnotation = nil;
    }
}

- (void)cleanUpMap
{
    if (self.placeVCShowed) {
        [self.placeViewController dismissViewControllerAnimated:YES completion:^ {
            self.placeVCShowed = NO;
            [self cleanUpMapAnnotationsAndOverlays];
        }];
    } else if (self.directionVCShowed) {
        [self.directionVC dismissViewControllerAnimated:YES completion:^ {
            self.directionVCShowed = NO;
            [self cleanUpMapAnnotationsAndOverlays];
        }];
    }
}

- (void)cleanUpMapAnnotationsAndOverlays
{
    [self.directionManager clearDirectionData];
    [self deHightlightPlace];
    [self removeDirectionsOverlay];
    [self removeCurrentAnnotation];
    
}

- (void)fitMapViewForPolygon:(MKPolygon *)polygon
{
    [self.mapView setVisibleMapRect:[self.mapView mapRectThatFits:polygon.boundingMapRect]
                        edgePadding:UIEdgeInsetsMake(64.0f, 0.0f, self.popupViewControllerHeight, 0.0f)
                           animated:YES];
}

- (void)fitMapViewForPolyline:(MKPolyline *)polyline
{
    [self.mapView setVisibleMapRect:[self.mapView mapRectThatFits:polyline.boundingMapRect]
                        edgePadding:UIEdgeInsetsMake(64.0f, 0.0f, self.popupViewControllerHeight, 0.0f)
                           animated:YES];
}

-(void)zoomToFitMapAnnotations
{
//    if([self.mapView.annotations count] == 0)
//        return;
//    
//    CLLocationCoordinate2D topLeftCoord;
//    topLeftCoord.latitude = -90;
//    topLeftCoord.longitude = 180;
//    
//    CLLocationCoordinate2D bottomRightCoord;
//    bottomRightCoord.latitude = 90;
//    bottomRightCoord.longitude = -180;
//    
//    for(id<MKAnnotation> annotation in self.mapView.annotations)
//    {
//        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
//        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
//        
//        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
//        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
//    }
//    
//    MKCoordinateRegion region;
//    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
//    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
//    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
//    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
//    
//    region = [self.mapView regionThatFits:region];
////    [self.mapView setRegion:region animated:YES];
//    [self.mapView setCenterCoordinate:region.center zoomLevel:[self getZoomLevel] animated:YES];
}

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
- (double) getZoomLevel
{
    return 21.00 - log2(self.mapView.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.mapView.bounds.size.width));
}

#pragma mark - override
- (void)setContainerSearchDisplayController:(UISearchDisplayController *)searchDisplayController containVC:(BBTMapContainerVC *)mapContainerVC;
{
    self.containerSearchDC = searchDisplayController;
    self.containerVC = mapContainerVC;
}

- (void)changeMapCampusRegion
{
    [self cleanUpMap];
    self.shouldResetCampusRegion = YES;
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    preferences.northCampus = !preferences.northCampus;
    if (preferences.northCampus) {
        [self.mapView switchToCampus:SCUTCampusNorth];
    } else {
        [self.mapView switchToCampus:SCUTCampusHEMC];
    }
}

- (void)resetMapRegion
{
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    if (preferences.northCampus) {
        [self.mapView switchToCampus:SCUTCampusNorth];
    } else {
        [self.mapView switchToCampus:SCUTCampusHEMC];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)
animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    BRSTostVCTransAnimator *animator = [[BRSTostVCTransAnimator alloc] init];
    animator.tostHeight = presented == self.directionVC ? 67.0f : 30.0f;
    animator.presenting = YES;
    self.shouldResetCampusRegion = NO;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)
animationControllerForDismissedController:(UIViewController *)dismissed
{
    BRSTostVCTransAnimator *animator = [[BRSTostVCTransAnimator alloc] init];
    animator.presenting = NO;
    self.shouldResetCampusRegion = NO;
    return animator;
}

@end
