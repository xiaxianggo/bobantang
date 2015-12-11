//
//  BBTPlaceView.h
//  bobantang
//
//  Created by Xia Xiang on 9/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRSPLaceViewDelegate;

@interface BRSPlaceView : UIView

@property (weak, nonatomic) id<BRSPLaceViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *dragIndicator;

- (void)changeToSmallMode;
- (void)changeToBigMode;
- (void)disableBigMode;
- (void)enableBigMode;

@end

@protocol BRSPLaceViewDelegate

- (void)didEnterBigModeWithPlaceView:(BRSPlaceView *)placeView ;
- (void)didEnterSmallModeWithPlaceView:(BRSPlaceView *)placeView ;
- (void)needDisapperaWithPlaceView:(BRSPlaceView *)placeView ;

@end
