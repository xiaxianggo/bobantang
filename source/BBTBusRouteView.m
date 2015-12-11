//
//  BBTBusRouteView.m
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTBusRouteView.h"

@interface BBTBusRouteView()

@property (nonatomic) NSUInteger count;
@end


@implementation BBTBusRouteView

- (void)setGreenCircles:(NSMutableArray *)greenDots
{
    _greenCircles = greenDots;
    [self setNeedsLayout];
}

- (void)setVioetDots:(NSMutableArray *)violetDots
{
    _violetCircles = violetDots;
    [self setNeedsLayout];
}

#define ROUTE_VIEW_TAG 42
- (instancetype)initWithFrame:(CGRect)frame Count:(NSUInteger)count
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    const CGFloat width = frame.size.width;
    const CGFloat elementHeight = frame.size.height / count;
    self.count = count;
    
    UIView *routeWarpper = [[UIView alloc] initWithFrame:self.bounds];
    routeWarpper.tag = ROUTE_VIEW_TAG;
    UIImage *routeElement = [UIImage imageNamed:@"route-element"];
    for (NSUInteger i = 0; i < count; i++) {
        CGFloat y = i * elementHeight;
        CGRect frame = CGRectMake(0.0, y, width, elementHeight);
        if (i == 0) {
            UIImage *routeHead = [UIImage imageNamed:@"route-head"];
            UIImageView *routeHeadView = [[UIImageView alloc] initWithImage:routeHead];
            routeHeadView.frame = frame;
            [routeWarpper addSubview:routeHeadView];
        } else if (i == count - 1) {
            UIImage *routeTail = [UIImage imageNamed:@"route-tail"];
            UIImageView *routeTailView = [[UIImageView alloc] initWithImage:routeTail];
            routeTailView.frame = frame;
            [routeWarpper addSubview:routeTailView];
        } else {
            UIImageView *routeElementView = [[UIImageView alloc] initWithImage:routeElement];
            routeElementView.frame = frame;
            [routeWarpper addSubview:routeElementView];
        }
    }
    [self addSubview:routeWarpper];
    
    return self;
}


#define CIRCLE_INIT_WIDTH 25.0f
- (void)layoutSubviews
{
    const CGFloat circleWidth = self.frame.size.width;
    const CGFloat elementHeight = self.frame.size.height / self.count;
    const CGFloat upPadding = 5.0f * (circleWidth / CIRCLE_INIT_WIDTH);
    for (UIView *thisView in self.subviews) {
        if (thisView.tag != ROUTE_VIEW_TAG) {
            [thisView removeFromSuperview];
        }
    }
    
    for (id dotIndex in self.greenCircles) {
        if ([dotIndex isKindOfClass:[NSNumber class]] &&
            [(NSNumber *)dotIndex integerValue] <= self.count
            ) {
            UIImageView *circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenCircle"]];
            CGFloat y = ( self.count - [(NSNumber*)dotIndex integerValue]) * elementHeight + upPadding;
            CGRect frame = CGRectMake(0.0, y , circleWidth, circleWidth);
            circle.frame = frame;
            [self addSubview:circle];
        }
    }
    
    for (id dotIndex in self.violetCircles) {
        if ([dotIndex isKindOfClass:[NSNumber class]] &&
            [(NSNumber *)dotIndex integerValue] <= self.count) {
            UIImageView *circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetCircle"]];
            CGFloat y = (self.count - [(NSNumber*)dotIndex integerValue]) * elementHeight + upPadding;
            CGRect frame = CGRectMake(0.0, y , circleWidth, circleWidth);
            circle.frame = frame;
            [self addSubview:circle];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
