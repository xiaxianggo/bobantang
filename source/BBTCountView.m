//
//  BBTCountView.m
//  bobantang
//
//  Created by Xia Xiang on 8/22/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTCountView.h"

@implementation BBTCountView

- (void)setState:(BBTCountViewState)state
{
    if (_state != state) {
        _state = state;
        [self setNeedsLayout];
    }
}

- (void)setState:(BBTCountViewState)state Count:(NSUInteger)count
{
    if ((_state != state) || (count != _count)) {
        _state = state;
        _count = count;
        [self setNeedsLayout];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [self.statePic removeFromSuperview];
    [self.countLabel removeFromSuperview];
    NSString *picName = @"";
    switch (self.state) {
        case BBTCountViewStateCounting:
            picName = @"greenLight";
            break;
        case BBTCountViewStateAlarm:
            picName = @"redLight";
            break;
        case BBTCountViewStateOff:
            picName = @"grayLight";
            break;
        default:
            break;
    }
    UIImage *statePic = [UIImage imageNamed:picName];
    UIImageView *statePicView = [[UIImageView alloc] initWithImage:statePic];
    statePicView.alpha = 0.8;
    self.statePic = statePicView;
    
    [self addSubview:self.statePic];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 12, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    NSString *labelText = @"";
    switch (self.state) {
        case BBTCountViewStateCounting:
            labelText = [NSString stringWithFormat:@"%lu", (unsigned long)[self count]];
            break;
        case BBTCountViewStateAlarm:
            labelText = @"!!";
            break;
        case BBTCountViewStateOff:
            labelText = @"0";
        default:
            break;
    }
    label.text = labelText;
    label.textColor = [UIColor whiteColor];
    self.countLabel = label;
    [self addSubview:self.countLabel];
}


-(void)performFlashAnimation
{
    [UIView animateWithDuration:2.0
                     animations:^(void) {
                         self.statePic.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.0
                                          animations:^(void) {
                                              self.statePic.alpha = 0.8;
                                          }];
                     }];
    //
    
    
}

@end
