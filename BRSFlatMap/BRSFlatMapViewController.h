//
//  BRSFlatMapViewController.h
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/15/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BRSSCUTMapView.h"
#import "BRSMapMetaDataManager.h"
#import "BBTMapViewController.h"

@interface BRSFlatMapViewController : BBTMapViewController <BRSMapViewDelegate, MKMapViewDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) BRSSCUTMapView *mapView;

@end
