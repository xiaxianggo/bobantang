//
//  BBTBusClusterView.h
//  bobantang
//
//  Created by Xia Xiang on 8/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBTBusClusterViewDelegate;

@interface BBTBusClusterView : UIView

@property (weak, nonatomic) id<BBTBusClusterViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame stationNames:(NSArray *)stationNames;
- (void)updateBusPosition;
- (void)restartBusAnimation;

@end


@protocol BBTBusClusterViewDelegate <NSObject>

- (void)BBTBusClusterView:(BBTBusClusterView *)clusterView didTapButtonAtIndex:(NSUInteger)index;

- (NSArray *)busKeysForBBTBusClusterView:(BBTBusClusterView *)clusterView;
- (BOOL)BBTBusClusterView:(BBTBusClusterView *)clusterView shouldDisplayBus:(NSString *)busKey;
- (BBTBusViewPosition)BBTBusClusterView:(BBTBusClusterView *)clusterView locationForBus:(NSString *)busKey;

@end