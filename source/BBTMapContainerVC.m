//
//  BBTMapViewController.m
//  bobantang
//
//  Created by Xia Xiang on 8/26/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "BBTTilesourceDownloadVC.h"
#import "BBTMapViewController.h"
#import "BRSFlatMapViewController.h"
#import "BBT3DMapViewController.h"
#import "UIButton+ASANUserTrackingButton.h"
#import "UIColor+BBTColor.h"
#import "BBTTileSourceManager.h"
#import "BBTMapContainerVC.h"

NSString *const kNorthCampusButtonTitle = @"N";
NSString *const kHEMCCampusButtonTitle = @"S";
NSString *const kFlatMapButtonTitle = @"2";
NSString *const k3DMapButtonTitle = @"2.5";

@interface BBTMapContainerVC() <UIAlertViewDelegate>
{
    BRSFlatMapViewController *_flatMapViewController;
    BBT3DMapViewController *_threeDMapViewController;
}

@property (nonatomic, readwrite) CGRect buttonGroupRect;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIButton *campusbutton;
@property (strong, nonatomic) UIButton *mapTypeButton;

/* map view container, note this is only the  CONTAINER */
@property (strong, nonatomic) UIView *mapViewContainer;

/* search and display */
@property (nonatomic, strong) UISearchDisplayController *searchDisplayContrl;
@property (nonatomic, strong) UISearchBar *searchBar;

/* map view controller */
@property (weak, nonatomic) BBTMapViewController *mapViewController;
@end


@implementation BBTMapContainerVC

#define MAP_TOOL_BAR_HEIGHT 44.0
- (void) loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    view.backgroundColor = [UIColor whiteColor];
    view.opaque = YES;
    self.view = view;
    
    //Set up container and its constraints
    self.mapViewContainer = ({
        UIView *mapViewContainer = [[UIView alloc] initWithFrame:appFrame];
        mapViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mapViewContainer;
    });
    [self.view addSubview:self.mapViewContainer];
    
    CGFloat buttonSize = 27.0f;
    NSString *campusButtonTitle = [BBTPreferences sharedInstance].northCampus ? kNorthCampusButtonTitle : kHEMCCampusButtonTitle;
    UIButton *campusButton = [UIButton ASANRoundRectButtonWithFrame:CGRectMake(appFrame.size.width - 1.3*buttonSize, 3.9 * buttonSize, buttonSize, buttonSize) title:campusButtonTitle];
    [campusButton addTarget:self action:@selector(campusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.campusbutton = campusButton;
    [self.view addSubview:self.campusbutton];
    
    NSString *mapTypeButtonTitle = [BBTPreferences sharedInstance].flatMap ? kFlatMapButtonTitle : k3DMapButtonTitle;
    UIButton *mapTypeButton = [UIButton ASANRoundRectButtonWithFrame:CGRectMake(appFrame.size.width - 1.3*buttonSize, 2.7 * buttonSize, buttonSize, buttonSize) title:mapTypeButtonTitle];
    [mapTypeButton addTarget:self action:@selector(mapTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.mapTypeButton = mapTypeButton;
    [self.view addSubview:self.mapTypeButton];
    
    UIButton *homeButton = [UIButton ASANRoundRectButtonWithFrame:CGRectMake(appFrame.size.width - 1.3*buttonSize, 5.1 * buttonSize, buttonSize, buttonSize)
                                                            image:[UIImage imageNamed:@"home"]];
    [homeButton addTarget:self action:@selector(homeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.homeButton = homeButton;
    [self.view addSubview:self.homeButton];
    
    self.buttonGroupRect = CGRectMake(campusButton.frame.origin.x - 10, 10 , buttonSize + 20, buttonSize * 5);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* search display controller */
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.showsCancelButton = NO;

    self.searchDisplayContrl = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayContrl.displaysSearchBarInNavigationBar = YES;
    
    /* init map view controller  */
    _flatMapViewController = [[BRSFlatMapViewController alloc] init];
    _threeDMapViewController = [[BBT3DMapViewController alloc] init];
    _threeDMapViewController.mapContainerVC = self;
    [_flatMapViewController setContainerSearchDisplayController:self.searchDisplayContrl containVC:self];
    [_threeDMapViewController setContainerSearchDisplayController:self.searchDisplayContrl containVC:self];
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    if (preferences.flatMap) {
        self.homeButton.hidden = NO;
        self.mapViewController = _flatMapViewController;
        self.searchBar.delegate = _flatMapViewController;
        self.searchDisplayContrl.delegate = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _flatMapViewController;
    } else {
        self.homeButton.hidden = YES;
        self.mapViewController = _threeDMapViewController;
        self.searchBar.delegate = _threeDMapViewController;
        self.searchDisplayContrl.delegate = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _threeDMapViewController;
    }
    
    /* bring map view controller to front */
    [self addChildViewController:self.mapViewController];
    [self.mapViewContainer addSubview:self.mapViewController.view];
    [self.mapViewController didMoveToParentViewController:self];
    
    
}

- (void)mapTypeButtonClicked:(UIButton *)sender
{
    if ([sender currentTitle] == kFlatMapButtonTitle) {
        // trans to 3D map
        if ([BBTTileSourceManager hasDownloadTilesource]) {
            NSLog(@"3d map tilesource downloaded");
            [sender setTitle:k3DMapButtonTitle forState:UIControlStateNormal];
            [self changeMapType];
            self.homeButton.hidden = YES;
        } else {
//TODO: ask user to download mbtiles
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"2.5D 地图包尚未下载" message:@"2.5D地图功能需要下载额外的地图包才能使用，现在去下载？\n(也可稍后在“设置-2.5D地图包下载”中下载)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去下载", nil];
            [alert show];

        }
    } else {
        [sender setTitle:kFlatMapButtonTitle forState:UIControlStateNormal];
        self.homeButton.hidden = NO;
        [self changeMapType];
    }
}

- (void)campusButtonClicked:(UIButton *)sender
{
    if ([sender currentTitle] == kNorthCampusButtonTitle) {
        [sender setTitle:kHEMCCampusButtonTitle forState:UIControlStateNormal];
        [self.mapViewController changeMapCampusRegion];
    } else {
        [sender setTitle:kNorthCampusButtonTitle forState:UIControlStateNormal];
        [self.mapViewController changeMapCampusRegion];
    }
}

- (void)homeButtonTapped:(UIButton *)sender
{
    [self.mapViewController resetMapRegion];
}

- (void)changeMapType
{
    /* remove current map view controller first */
    [self.mapViewController willMoveToParentViewController:nil];
    [self.mapViewController.view removeFromSuperview];
    [self.mapViewController removeFromParentViewController];
    
    /* change prefered map type */
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    preferences.flatMap = !preferences.flatMap;
    /* init new map view controller */
    if (preferences.flatMap) {
        self.mapViewController = _flatMapViewController;
        self.searchBar.delegate = _flatMapViewController;
        self.searchDisplayContrl.delegate = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _flatMapViewController;
    } else {
        self.mapViewController = _threeDMapViewController;
        self.searchBar.delegate = _threeDMapViewController;
        self.searchDisplayContrl.delegate = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _threeDMapViewController;
    }
    [self addChildViewController:self.mapViewController];
    [self.mapViewContainer addSubview:self.mapViewController.view];
    [self.mapViewController didMoveToParentViewController:self];
}

- (void)fallbackToFlatMap
{
    /* change prefered map type */
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    if (preferences.flatMap) {
        return; // already flat map, don't need to fallback
    }
    
    /* remove current map view controller first */
    [self.mapViewController willMoveToParentViewController:nil];
    [self.mapViewController.view removeFromSuperview];
    [self.mapViewController removeFromParentViewController];
    
    self.mapViewController = _flatMapViewController;
    self.searchBar.delegate = _flatMapViewController;
    self.searchDisplayContrl.delegate = _flatMapViewController;
    self.searchDisplayContrl.searchResultsDataSource = _flatMapViewController;
    self.searchDisplayContrl.searchResultsDelegate = _flatMapViewController;
    [self addChildViewController:self.mapViewController];
    [self.mapViewContainer addSubview:self.mapViewController.view];
    [self.mapViewController didMoveToParentViewController:self];
    preferences.flatMap = YES;
    self.homeButton.hidden = NO;
    [self.mapTypeButton setTitle:kFlatMapButtonTitle forState:UIControlStateNormal];
}

#pragma mark - UIAlertViewDelegte

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 for cancle
    // 1 for go to download
    if (buttonIndex == 1) {
        BBTTilesourceDownloadVC *tilesourceDownloadVC = [[BBTTilesourceDownloadVC alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:tilesourceDownloadVC];
        [self presentViewController:navigationVC animated:YES completion:NULL];
    }
}

@end
