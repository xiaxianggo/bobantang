//
//  BBTBusView.m
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTBusView.h"

@implementation BBTBusView

- (void)setDirection:(BBTBusDirection)direction
{
    if (_direction != direction) {
        _direction = direction;
        [self setNeedsLayout];
    }
}

#define BUS_VIEW_HEIGHT 32
#define BUS_VIEW_WIDTH 38
-(void)layoutSubviews
{
    [self.busPic removeFromSuperview];
    [self.arrowView removeFromSuperview];
    [self.slashView removeFromSuperview];
    
    if (self.direction == BBTBusDirectionSourth) {
        self.busPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetBus"]];
        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetDownArrow"]];
        self.slashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slash"]];
        CGRect frameForBus = CGRectMake(0, 0, BUS_VIEW_WIDTH, BUS_VIEW_HEIGHT);
        CGRect frameForSlash = CGRectMake(0, BUS_VIEW_HEIGHT / 2.0 + 2.0, BUS_VIEW_WIDTH * 0.9, 1.5);
        self.busPic.frame = frameForBus;
        self.arrowView.frame = frameForBus;
        self.slashView.frame = frameForSlash;
        self.slashView.alpha = 0.42;
        
    } else {
        self.busPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBus"]];
        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenUpArrow"]];
        CGRect frameForBus = CGRectMake(0, 0, BUS_VIEW_WIDTH, BUS_VIEW_HEIGHT);
        self.busPic.frame = frameForBus;
        self.arrowView.frame = frameForBus;
        self.slashView = nil;
    }
    
    self.arrowView.alpha = 0.0;
    [self addSubview:self.arrowView];
    [self addSubview:self.busPic];
    [self addSubview:self.slashView];
    
    if (self.direction == BBTBusDirectionSourth) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             self.busPic.frame = CGRectMake(BUS_VIEW_WIDTH, 0, BUS_VIEW_WIDTH, BUS_VIEW_HEIGHT);
                             self.arrowView.frame = CGRectMake(BUS_VIEW_WIDTH, 0, BUS_VIEW_WIDTH, BUS_VIEW_HEIGHT);
                             self.slashView.frame = CGRectMake(0, BUS_VIEW_HEIGHT / 2.0, BUS_VIEW_WIDTH * 0.9, 1.5);
                         }
                         completion:^(BOOL finish) {
                             if (finish) {
                                 [UIView animateWithDuration:5.0 delay:0.0
                                                     options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseInOut
                                                  animations:^(void) {
                                                      self.busPic.alpha = 0.0;
                                                      self.arrowView.alpha = 1.0;
                                                  } completion:NULL];
                             }}];
    } else {
        [UIView animateWithDuration:5.0
                              delay:0.0
                            options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             self.busPic.alpha = 0.0;
                             self.arrowView.alpha = 1.0;
                         }
                         completion:NULL];
    }
}

- (id)initWithFrame:(CGRect)frame direction:(BBTBusDirection)direction
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.direction = direction;
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
