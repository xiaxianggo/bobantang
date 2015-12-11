//
//  BRSMapSearchController.m
//  BRSFlatMap
//
//  Created by Xia Xiang on 7/20/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BRSMapSearchHelper.h"
#import "BRSMapMetaDataManager.h"

@interface BRSMapSearchHelper()

@property (nonatomic, strong) MKLocalSearch *localSearch;

@end

@implementation BRSMapSearchHelper

- (NSMutableArray *)saerchResult
{
    if (!_saerchResult) {
        _saerchResult = [NSMutableArray array];
    }
    return _saerchResult;
}

#pragma mark - Search Method
- (void)startSearch:(NSString *)searchString forLocation:(CLLocationCoordinate2D)location
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = location.latitude;
    newRegion.center.longitude = location.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [self.delegate mapSearchController:self didGetSearchResponse:response];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil) {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)searchLocal:(NSString *)searchString
{
    
}

- (void)updateSearchResultForKeyword:(NSString *) keyword
{
    [self.saerchResult removeAllObjects];
    NSArray *places = [self.delegate mapDataForSearchHelper:self];
    for (BRSPlace *place in places) {
        NSRange range = [place.title rangeOfString:keyword options:NSCaseInsensitiveSearch];
        
        if (range.location != NSNotFound) {
            [self.saerchResult addObject:place];
        }
    }
}

@end
