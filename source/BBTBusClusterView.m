//
//  BBTBusClusterView.m
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIButton+BBTStationButton.h"
#import "BBTBusClusterView.h"
#import "BBTBusRouteView.h"
#import "BBTBusView.h"

@interface BBTBusClusterView()
@property (nonatomic) CGFloat elementHeight;
@property (nonatomic) CGFloat elementY;
@property (strong, nonatomic) NSArray *stationNames;

@property (strong, nonatomic) BBTBusRouteView *routeView;
@property (strong, nonatomic) NSMutableDictionary *busViews;

@end

@implementation BBTBusClusterView

#define ROUTE_VIEW_X 160.f
#define ROUTE_VIEW_INIT_WIDTH 25.0f
#define ROUTE_VIEW_INIT_HEIGHT 420.f
#define STATION_BUTTON_X 76.0f
#define UP_PADDING 6.0f
#define STATION_BUTTON_WIDTH 67.f
#define STATION_BUTTON_HEIGHT 20.0f
- (instancetype)initWithFrame:(CGRect)frame stationNames:(NSArray *)stationNames
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.stationNames = stationNames;

    NSUInteger count = [self.stationNames count];
    CGFloat elementHeight = self.frame.size.height / count;
    self.elementHeight = elementHeight;
    self.elementY = 0.0f;

    /* add route view */
    CGFloat routeViewFactor = self.frame.size.height / ROUTE_VIEW_INIT_HEIGHT;
    CGFloat routeViewWidth = ROUTE_VIEW_INIT_WIDTH * routeViewFactor;
    CGRect routeViewFrame = CGRectMake(ROUTE_VIEW_X, 0.0f, routeViewWidth, self.frame.size.height);
    self.routeView = [[BBTBusRouteView alloc] initWithFrame:routeViewFrame Count:count];
    [self addSubview:self.routeView];
    [self bringSubviewToFront:self.routeView];
    
    /* add station buttons */
    for (NSUInteger i = 0; i < count; i++) {
        UIButton *stationButton = [UIButton stationButtonWithName:self.stationNames[i]];
        stationButton.tag = i;
        [stationButton addTarget:self action:@selector(stationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat y = i * elementHeight + UP_PADDING;
        stationButton.frame = CGRectMake(STATION_BUTTON_X, y, STATION_BUTTON_WIDTH, STATION_BUTTON_HEIGHT);
        [self addSubview:stationButton];
    }

    return self;
}

- (NSMutableDictionary *)busViews
{
    if (!_busViews) {
        _busViews = [NSMutableDictionary dictionary];
    }
    return _busViews;
}
#define BUS_INIT_X 196.0f
#define BUS_INIT_Y 0.0f
#define BUS_WIDTH 32.0f
#define BUS_HEIGHT 38.0f
#define BUS_MOVE_ANIMATION_DURATION 0.5f
- (void)updateBusPosition
{
    NSArray *busKeys = [self.delegate busKeysForBBTBusClusterView:self];
    if ([busKeys count] == 0) {
        return;
    }
    
    for (NSString *key in busKeys) {
        BBTBusView *busView = self.busViews[key];
        if (!busView) {
            busView = [[BBTBusView alloc] initWithFrame:CGRectMake(BUS_INIT_X, BUS_INIT_Y, BUS_WIDTH, BUS_HEIGHT) direction:YES];
            busView.hidden = YES;
            [self.busViews setObject:busView forKey:key];
            [self addSubview:busView];
        }
    }
    
    NSMutableArray *greenCircles = [NSMutableArray array];
    NSMutableArray *violetCircles = [NSMutableArray array];
    for (NSString *key in busKeys) {
        BBTBusView *busView = self.busViews[key];
        if ([self.delegate BBTBusClusterView:self shouldDisplayBus:key]) {
            BBTBusViewPosition position = [self.delegate BBTBusClusterView:self locationForBus:key];
            if (position.direction == BBTBusDirectionSourth) {
                [violetCircles addObject:@(position.stationIndex)];
            } else {
                [greenCircles addObject:@(position.stationIndex)];
            }
            busView.hidden = NO;
            busView.direction = position.direction;
            [UIView animateWithDuration:BUS_MOVE_ANIMATION_DURATION animations:^(void) {
                busView.frame = [self frameForBusPosition:position];
            }];
        } else {
            busView.hidden = YES;
            continue;
        }
    }
    self.routeView.greenCircles = greenCircles;
    self.routeView.violetCircles = violetCircles;
}

- (void)restartBusAnimation
{
    for (NSString *key in [self.busViews allKeys]) {
        BBTBusView *busView = self.busViews[key];
            [busView setNeedsLayout];
    }
}

- (CGRect)frameForBusPosition:(BBTBusViewPosition)position
{
    CGFloat directionFactor = position.direction == BBTBusDirectionSourth ? -1.0f : 1.0f;
    CGFloat y = self.frame.size.height - self.elementY - (position.stationIndex * self.elementHeight + directionFactor * position.percent * self.elementHeight);
    return CGRectMake(BUS_INIT_X, y, BUS_WIDTH, BUS_HEIGHT);
}

- (void)stationButtonTapped:(UIButton *)button
{
    [self.delegate BBTBusClusterView:self didTapButtonAtIndex:button.tag];
}

@end
