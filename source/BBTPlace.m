//
//  BBTPlace.m
//  bobantang
//
//  Created by Xia Xiang on 8/31/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BBTPlace.h"

@implementation BBTPlace

- (instancetype)initWithCoord:(CLLocationCoordinate2D)coord title:(NSString *)title keywords:(NSArray *)keywords
{
    self = [super init];
    if (self) {
        self.coordinates = coord;
        self.title = title;
        self.keywords = keywords;
    }
    return self;
}
@end
