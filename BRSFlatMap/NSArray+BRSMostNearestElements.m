//
//  NSArray+BRSMostNearestElements.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "NSArray+BRSMostNearestElements.h"

@implementation NSArray (BRSMostNearestElements)


//TODO: still buggy....... fix it
 -(NSArray *)most:(NSUInteger)count NearstElements:(NSComparisonResult (^)(id, id))cmptr
{
    NSArray *sortedArray = [self sortedArrayUsingComparator:cmptr];
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        [resultArray addObject:sortedArray[i]];
    }
    return [resultArray copy];
}
@end
