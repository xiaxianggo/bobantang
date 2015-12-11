//
//  BRSPlaceViewController.h
//  bobantang
//
//  Created by Xia Xiang on 8/27/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSPlace.h"

@protocol BRSTPlaceVCdelegate;

@interface BRSPlaceViewController : UIViewController

@property (strong, nonatomic) NSArray *places; // of BRSPlace
@property (weak, nonatomic) id<BRSTPlaceVCdelegate> delegate;

@end

@protocol BRSTPlaceVCdelegate
- (void)placeVC:(BRSPlaceViewController *)placeVC didEnterMode:(BOOL)mode;
- (void)didDismissPlaceVC:(BRSPlaceViewController *)placeVC;
- (void)didPresentPlaceVC:(BRSPlaceViewController *)placeVC;
- (void)placeVC:(BRSPlaceViewController *)placeVC didSelectPlace:(BRSPlace *)place;
- (void)placeVC:(BRSPlaceViewController *)placeVC needDirectionsFrom:(BRSPlace *)sourcePlace;
- (void)placeVC:(BRSPlaceViewController *)placeVC needDirectionsTo:(BRSPlace *)destnationPlace;

@end
