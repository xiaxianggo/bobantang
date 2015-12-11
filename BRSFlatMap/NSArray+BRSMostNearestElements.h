//
//  NSArray+BRSMostNearestElements.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 8/19/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (BRSMostNearestElements)

- (NSArray *)most:(NSUInteger)count NearstElements:(NSComparisonResult (^)(id obj1, id obj2))cmptr;

@end
