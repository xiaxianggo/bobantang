//
//  BBTDirectionsManager.m
//  bobantang
//
//  Created by Xia Xiang on 9/11/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "SVProgressHUD.h"
#import "BBTDirectionsManager.h"

NSString *const kBBTDirectionDidGetResponse = @"BBTDirectionDidGetResponse";

@implementation BBTDirectionsManager

- (BOOL)readToDirect
{
    return self.sourcePlace && self.destnationPlace;
}

- (void)directionStart
{
    self.directionResponse = nil;
    
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    [request setSource:[self.sourcePlace convertToMKMapItem]];
    //[request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:[self.destnationPlace convertToMKMapItem]];
    request.transportType = MKDirectionsTransportTypeWalking;
    request.requestsAlternateRoutes = NO;
    
    NSLog(@"yooooooo Start Direction!!!");
    if (self.directions.isCalculating) {
        [self.directions cancel];
    }
    self.directions = [[MKDirections alloc] initWithRequest:request];
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSLog(@"!!!!cannot get directions");
            [[NSNotificationCenter defaultCenter] postNotificationName:kBBTDirectionDidGetResponse
                                                                object:self
                                                              userInfo:@{@"hasErr" : @(YES),
                                                                         @"error" : error}];
        } else {
            NSLog(@"did get directions!!!");
            self.directionResponse = response;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBBTDirectionDidGetResponse
                                                                object:self
                                                              userInfo:@{@"hasErr" : @(NO)}];

        }
    }];
}

- (void)clearDirectionData
{
    self.sourcePlace = nil;
    self.destnationPlace = nil;
    self.directionResponse = nil;
}

- (BOOL)alreadyHaveDirections
{
    return (self.sourcePlace && self.destnationPlace && self.directionResponse);
}

-(NSString *)distanceAndTravelTimeString
{
    NSString *stringForResponse;
    if (self.directionResponse) {
        MKRoute *route = [self.directionResponse.routes firstObject];
        NSInteger minutes = floor(route.expectedTravelTime / 60);
        NSInteger seconds = round(route.expectedTravelTime - minutes * 60);
        NSString *timeString = [NSString stringWithFormat:@"%ld分%ld秒", (long)minutes, (long)seconds];
        NSInteger meter = round(route.distance);
        stringForResponse = [NSString stringWithFormat:@"距离:%ld米，时间:%@ (步行)", (long)meter, timeString];
    } else {
        stringForResponse = @"";
    }
    return stringForResponse;
}
@end
