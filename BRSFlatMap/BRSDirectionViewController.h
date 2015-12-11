//
//  BRSDirectionViewController.h
//  bobantang
//
//  Created by Xia Xiang on 9/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSMapMetaDataManager.h"
#import "BBTDirectionsManager.h"

@protocol BRSDirectionViewControllerDelegate;

@interface BRSDirectionViewController : UIViewController

@property (weak, nonatomic) id<BRSDirectionViewControllerDelegate> delegate;

@property (strong, nonatomic) BRSPlace *startPlace;
@property (strong, nonatomic) BRSPlace *endPlace;

@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL fullMode;

- (id)initWithDataManager:(BRSMapMetaDataManager *)dataManager directionManager:(BBTDirectionsManager *)directionManager;

@end

@protocol BRSDirectionViewControllerDelegate

- (void)directionVC:(BRSDirectionViewController *)vc didGetDirectionResponse:(MKDirectionsResponse *)response;
- (void)directionVCdidEnterBigMode:(BRSDirectionViewController *)vc;
- (void)directionVCdidEnterSmallMode:(BRSDirectionViewController *)vc;
- (void)directionVCDidPresent:(BRSDirectionViewController *)vc;
- (void)directionVCDidDismiss:(BRSDirectionViewController *)vc;

@end
