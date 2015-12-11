//
//  BBT3DMapManager.h
//  bobantang
//
//  Created by Xia Xiang on 8/30/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBT3DMapMetaDataManager : NSObject

@property (strong, nonatomic, readonly) NSArray *metaData;
@property (strong, nonatomic, readonly) NSMutableArray *searchResult;

- (void)updateSearchResultForKeyword:(NSString *)keyword;
@end
