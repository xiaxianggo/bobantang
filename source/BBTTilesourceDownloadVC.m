//
//  BBTTilesourceDownloadVC.m
//  bobantang
//
//  Created by Xia Xiang on 10/4/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <CRToast/CRToast.h>
#import "BBTTilesourceDownloadVC.h"
#import "BBTTileSourceManager.h"
#import "BBTDownloadCell.h"
#define DOWNLOAD_VIEW_SECTION 0
#define DOWNLOAD_BUTTON_SECTION 1


@interface BBTTilesourceDownloadVC () <BBTTileSourceManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) BBTTileSourceManager *tilesourceManager; // singleton , don't need a strong pointer
@property (nonatomic, strong) UITableViewCell *downloadButtonCell;
@property (nonatomic, strong) BBTDownloadCell *downloadCell;
@property (nonatomic, weak) UIProgressView *downloadProgressView;
@property (nonatomic, weak) UILabel *downloadedConutLabel;
@property (nonatomic, weak) UILabel *totalSizeLabel;
@end

@implementation BBTTilesourceDownloadVC

static NSString *downloadViewCellIdentifier = @"BBTDownloadCell";
static NSString *downloadButtonCellIdentifier = @"BBTDownloadButtonCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"2.5D地图包下载";
    
    self.downloadButtonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:downloadButtonCellIdentifier];
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BBTDownloadCell" owner:self options:nil];
    self.downloadCell = (BBTDownloadCell *)[nibs firstObject];
    self.downloadCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.downloadProgressView = self.downloadCell.downloadProgressView;
    self.downloadProgressView.progress = 0.0f;
    self.downloadedConutLabel = self.downloadCell.downloadedCountLabel;
    self.totalSizeLabel = self.downloadCell.fullSizeCountLabel;
    
    // if self is the root view controller, this controller is present modaly, add a cancle.
    if (self.navigationController.childViewControllers.firstObject == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(cancleButtonTapped:)];
    }
}

- (void)cancleButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tilesourceManager = [BBTTileSourceManager sharedTilesourceManager];
    self.tilesourceManager.delegate = self;
    
    long long totalSize = self.tilesourceManager.totalContentSize;
    NSInteger total = lroundl(totalSize / 1024 / 1024);
    self.totalSizeLabel.text = [NSString stringWithFormat:@"/%ldMB", (long)total];

    [self updateUI];
}

- (void)toogleDownloadButton
{
    if (self.tilesourceManager.hasDownloadSession) {
        switch (self.tilesourceManager.downloadState) {
            case BBTTileSourceManagerStateDownloading:
                [self.tilesourceManager suspendDownload];
                break;
            case BBTTileSourceManagerStateUnzipping:
                break;
            case BBTTileSourceManagerStateSuspended:
                [self.tilesourceManager startDownload];
                break;
            case BBTTileSourceManagerStateFailed:
                [self.tilesourceManager startDownload];
                break;
            default:
                break;
        }
    } else {
        if ([BBTTileSourceManager hasDownloadTilesource]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认要删除地图包么？"
                                                            message:@"删除地图包之后，需要重新下载才能使用 2.5D 地图功能。"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"删除", nil];
            [alert show];
        } else {
            [self.tilesourceManager startDownload];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1; // the download view section and download button both have only one row.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;// one for download view, one for download button
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == DOWNLOAD_BUTTON_SECTION) {
        [self toogleDownloadButton];
        [self updateUI];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DOWNLOAD_BUTTON_SECTION) {
        return 32.0f;
    } else if (indexPath.section == DOWNLOAD_VIEW_SECTION) {
        return 76.0f;
    } else {
        return 23.0f;
    }
}


#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DOWNLOAD_VIEW_SECTION) {
        return self.downloadCell;
    } else if (indexPath.section == DOWNLOAD_BUTTON_SECTION) {
        return self.downloadButtonCell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:downloadViewCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:downloadViewCellIdentifier];
        }
        return cell;
    }
}

- (void)updateUI
{
    NSLog(@"update UI get called");
    [self adjustDownloadButtonCell:self.downloadButtonCell];
    [self adjustDownloadCell:self.downloadCell];
}

- (void)adjustDownloadButtonCell:(UITableViewCell *)cell
{
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (self.tilesourceManager.hasDownloadSession) {
        switch (self.tilesourceManager.downloadState) {
            case BBTTileSourceManagerStateDownloading:
                cell.textLabel.text = @"暂停下载";
                cell.textLabel.textColor = [UIColor BBTAppGlobalBlue];
                break;
            case BBTTileSourceManagerStateUnzipping:
                cell.textLabel.text = @"暂停下载";
                cell.textLabel.textColor = [UIColor grayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case BBTTileSourceManagerStateSuspended:
                cell.textLabel.text = @"开始下载";
                cell.textLabel.textColor = [UIColor BBTAppGlobalBlue];
                break;
            case BBTTileSourceManagerStateFailed:
                cell.textLabel.text = @"开始下载";
                cell.textLabel.textColor = [UIColor BBTAppGlobalBlue];
                break;
            default:
                break;
        }
    } else {
        if ([BBTTileSourceManager hasDownloadTilesource]) {
            cell.textLabel.text = @"删除地图包";
            cell.textLabel.textColor = [UIColor redColor];
        } else {
            cell.textLabel.text = @"开始下载";
            cell.textLabel.textColor = [UIColor BBTAppGlobalBlue];
        }
    }
    
}

- (void)adjustDownloadCell:(BBTDownloadCell *)cell
{
    if (self.tilesourceManager.hasDownloadSession) {
        cell.downloadProgressView.hidden = NO;
        cell.downloadedCountLabel.hidden = NO;
        cell.fullSizeCountLabel.hidden = NO;
        switch (self.tilesourceManager.downloadState) {
            case BBTTileSourceManagerStateDownloading:
                cell.downloadStatLabel.text = @"下载中...";
                break;
            case BBTTileSourceManagerStateUnzipping:
                cell.downloadStatLabel.text = @"解压中...";
                break;
            case BBTTileSourceManagerStateSuspended:
                cell.downloadStatLabel.text = @"已暂停";
                break;
            case BBTTileSourceManagerStateFailed:
                cell.downloadStatLabel.text = @"下载失败 :(";
                break;
            default:
                break;
        }
    } else {
        cell.downloadProgressView.hidden = YES;
        cell.downloadedCountLabel.hidden = YES;
        cell.fullSizeCountLabel.hidden = YES;
        if ([BBTTileSourceManager hasDownloadTilesource]) {
            cell.downloadStatLabel.text = @"✅地图包已下载";
        } else {
            cell.downloadStatLabel.text = @"地图包尚未下载";
        }
    }
}

#pragma mark - BBTTilesourceManagerDelegate
- (void)tilesourceManager:(BBTTileSourceManager *)manager didReceiveFirstResponse:(NSURLResponse *)response
{
    NSLog(@"download start!!!");
    [self updateUI];
    long long totalSize = self.tilesourceManager.totalContentSize;
    NSInteger total = lroundl(totalSize / 1024 / 1024);
    self.totalSizeLabel.text = [NSString stringWithFormat:@"/%ldMB", (long)total];
}

- (void)tilesourceManager:(BBTTileSourceManager *)manager didReceiveData:(uint64_t)received onTotal:(uint64_t)total
{
    NSLog(@"Receive data!!! %llu / %llu", received, total);
    NSInteger totalSize = lroundl(self.tilesourceManager.totalContentSize / 1024 / 1024);
    NSInteger downloaded = lroundl(received / 1024 / 1024);
    self.downloadProgressView.progress = (float)downloaded / (float)totalSize;
    self.downloadedConutLabel.text = [NSString stringWithFormat:@"%ldMB", (long)downloaded];
}

- (void)tilesourceManager:(BBTTileSourceManager *)manager didStopWithError:(NSError *)error
{
    NSLog(@"ERRRRRRRRRRR STOP");
    [self updateUI];
}

- (void)tilesourceManager:(BBTTileSourceManager *)manager didFinishDownloadWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    if (downloadFinished) {
        NSLog(@"Download Finish, start unzip!!!");
    } else {
        NSLog(@"Download suspended");
    }
    [self updateUI];
}

- (void)tilesourceManager:(BBTTileSourceManager *)manager didFinishUnzipWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile;
{
    NSLog(@"Unzip finished!!!!!");
    [self updateUI];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"%d", buttonIndex);
    // 0 for cancle
    // 1 for delete!
    if (buttonIndex == 1) {
        [self.tilesourceManager removeTileSourceFiles];
        [self updateUI];
    }
}
@end
