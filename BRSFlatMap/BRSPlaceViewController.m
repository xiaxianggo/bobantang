//
//  BRSPlaceViewController.m
//  bobantang
//
//  Created by Xia Xiang on 8/27/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BRSPlaceViewController.h"
#import "BRSPlaceView.h"

@interface BRSPlaceViewController() <UITableViewDataSource, UITableViewDelegate, BRSPLaceViewDelegate>

@property (strong, nonatomic) BRSPlaceView *placeView;

@end

@implementation BRSPlaceViewController

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self updatePlacesInfo];
}

- (void)loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat bigModeHeight = 276.0f;
    
    self.placeView = ({
        BRSPlaceView *view = [[BRSPlaceView alloc] init];
        view.frame = CGRectMake(0.0f, 0.0f, appFrame.size.width, bigModeHeight);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = [UIColor whiteColor];
        view.opaque = YES;
        view.delegate = self;
        view.tableView.dataSource = self;
        view.tableView.delegate = self;
        view.placeLabel.text = @"";
        view.categoryLabel.text = @"";
        [view.fromButton addTarget:self action:@selector(toogleDirection:) forControlEvents:UIControlEventTouchUpInside];
        [view.toButton addTarget:self action:@selector(toogleDirection:) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
   

    self.view = self.placeView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.delegate didPresentPlaceVC:self];
    [self.delegate didPresentPlaceVC:self];
    [self updatePlacesInfo];
    
}

- (void)updatePlacesInfo
{
    if ([self.places count] == 1) {
        BRSPlace *place = (BRSPlace *)self.places.firstObject;
        if ([place.subPlaces count] == 0) {
            [self.placeView disableBigMode];
        } else {
            [self.placeView enableBigMode];
        }
        [self.placeView changeToSmallMode];
        self.placeView.placeLabel.text = place.title;
        self.placeView.categoryLabel.text = place.type;
    } else {
        [self.placeView enableBigMode];
        [self.placeView changeToBigMode];
        self.placeView.placeLabel.text = @"标记附近的地点有：";
        self.placeView.categoryLabel.text = @"";
    }
    
    [self.placeView.tableView reloadData];
}

#pragma mark - BRSPlaceViewDelegate
- (void)didEnterSmallModeWithPlaceView:(BRSPlaceView *)placeView
{
    [self.delegate placeVC:self didEnterMode:NO];
}

- (void)didEnterBigModeWithPlaceView:(BRSPlaceView *)placeView
{
    [self.delegate placeVC:self didEnterMode:YES];
}

- (void)needDisapperaWithPlaceView:(BRSPlaceView *)placeView
{
    [self.delegate didDismissPlaceVC:self];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.places count] == 1) {
        return;
    } else {
        [self.delegate placeVC:self didSelectPlace:self.places[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.places count] == 1) { //detail mode
        return 30.0f;
    } else {            // surrounding mode
        return 42.0f;
    }
}

#pragma mark - UItableViewDataSouce
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *placeCellId = @"placeViewerPlcaeCell";
    static NSString *subPlcaeCellId = @"placeViewerSubPlcaeCell";
    
    UITableViewCell *cell;
    if ([self.places count] == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:placeCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:placeCellId];
        }
        BRSPlace *place = (BRSPlace *)self.places.firstObject;
        cell.textLabel.text = place.subPlaces[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:subPlcaeCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:subPlcaeCellId];
        }
        BRSPlace *place = (BRSPlace *)self.places[indexPath.row];
        cell.textLabel.text = place.title;
        cell.detailTextLabel.text = place.type;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.places count] == 1) {
        return [((BRSPlace *)self.places.firstObject).subPlaces count];
    } else {
        return [self.places count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.places count] == 1) {
        return @"建筑内部单位";
    } else {
        return @"";
    }
}

- (void)toogleDirection:(UIButton *)button
{
    NSLog(@"from button");
    if (button == self.placeView.fromButton) {
        NSLog(@"from button");
        [self.delegate placeVC:self needDirectionsFrom:[self.places firstObject]];
    } else if (button == self.placeView.toButton) {
        NSLog(@"to button");
        [self.delegate placeVC:self needDirectionsTo:[self.places firstObject]];
    }
}
@end
