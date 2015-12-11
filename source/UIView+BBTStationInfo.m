//
//  UIView+BBTStationInfo.m
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIView+BBTStationInfo.h"
#import "UIColor+BBTColor.h"
@implementation UIView (BBTStationInfo)

+ (UIView *)BBTStationInfoContentViewWithName:(NSString *)name info:(NSString *)info
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 256, 176)];
    
    CGRect stationLabelRect = contentView.bounds;
    stationLabelRect.origin.y = 20;
    stationLabelRect.size.height = 20;
    UIFont *stationLabelFont = [UIFont boldSystemFontOfSize:23];
    UILabel *stationLabel = [[UILabel alloc] initWithFrame:stationLabelRect];
    stationLabel.text = name;
    stationLabel.font = stationLabelFont;
    stationLabel.textColor = [UIColor BBTAppGlobalBlue];
    stationLabel.textAlignment = NSTextAlignmentCenter;
    stationLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:stationLabel];
    
    CGRect infoLabelRect = CGRectInset(contentView.bounds, 5, 5);
    infoLabelRect.origin.y = CGRectGetMaxY(stationLabelRect)+5;
    infoLabelRect.size.height -= CGRectGetMinY(infoLabelRect);
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:infoLabelRect];
    infoLabel.text = info;
    infoLabel.font = [UIFont systemFontOfSize:17];
    infoLabel.numberOfLines = 6;
    infoLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:infoLabel];
    return contentView;
}
@end
