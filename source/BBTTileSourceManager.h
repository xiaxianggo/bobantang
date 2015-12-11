//
//  BBTTileSourceManager.h
//  bobantang
//
//  Created by Xia Xiang on 10/4/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <Mapbox.h>
#import <Foundation/Foundation.h>
#import <TCBlobDownload/TCBlobDownload.h>


typedef enum : NSUInteger {
    BBTTileSourceManagerStateDownloading = 0,
    BBTTileSourceManagerStateFailed,
    BBTTileSourceManagerStateSuspended,
    BBTTileSourceManagerStateUnzipping
} BBTTileSourceManagerState;

@protocol BBTTileSourceManagerDelegate;


@interface BBTTileSourceManager : NSObject

@property (nonatomic, readonly) double downloadProgress;
@property (nonatomic, readonly) BOOL hasDownloadSession;
@property (nonatomic, strong, readonly) TCBlobDownloader *downloader;
@property (nonatomic, weak) id<BBTTileSourceManagerDelegate> delegate;
@property (nonatomic, readonly) BBTTileSourceManagerState downloadState;

@property (nonatomic, readonly) long long totalContentSize;

- (void)startDownload;
- (void)cancleDownload;
- (void)suspendDownload;

- (void)removeTileSourceFiles;


+ (instancetype)sharedTilesourceManager;

+ (RMMBTilesSource *)northCampusTile;
+ (RMMBTilesSource *)HEMCCampusTile;

+ (BOOL)hasDownloadTilesource;

@end


@protocol BBTTileSourceManagerDelegate

- (void)tilesourceManager:(BBTTileSourceManager *)manager didReceiveFirstResponse:(NSURLResponse *)response;
- (void)tilesourceManager:(BBTTileSourceManager *)manager didReceiveData:(uint64_t)received onTotal:(uint64_t)total;
- (void)tilesourceManager:(BBTTileSourceManager *)manager didStopWithError:(NSError *)error;
- (void)tilesourceManager:(BBTTileSourceManager *)manager didFinishDownloadWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile;
- (void)tilesourceManager:(BBTTileSourceManager *)manager didFinishUnzipWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile;

@end