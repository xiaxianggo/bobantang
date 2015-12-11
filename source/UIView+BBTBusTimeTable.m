//
//  UIView+BBTBusTimeTable.m
//  bobantang
//
//  Created by Xia Xiang on 8/22/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "UIView+BBTBusTimeTable.h"

@implementation UIView (BBTBusTimeTable)

+ (UIView *)BBTTimeTableView
{
    UIImage *timeTableImg = [UIImage imageNamed:@"timetable"];
    UIImageView *timeTableView = [[UIImageView alloc] initWithImage:timeTableImg];
    return timeTableView;
}
@end
