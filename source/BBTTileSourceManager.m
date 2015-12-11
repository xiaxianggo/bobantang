//
//  BBTTileSourceManager.m
//  bobantang
//
//  Created by Xia Xiang on 10/4/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <CRToast/CRToast.h>
#import <AFNetworking.h>
#import <zipzap/zipzap.h>
#import "BBTTileSourceManager.h"


@interface BBTTileSourceManager() {
    dispatch_queue_t _queue;
}
@property (nonatomic, readwrite) double downloadProgress;
@property (nonatomic, strong, readwrite) TCBlobDownloader *downloader;
@property (nonatomic, readwrite) BOOL hasDownloadSession;
@property (nonatomic, readwrite) BBTTileSourceManagerState downloadState;

@property (nonatomic, readwrite) long long totalContentSize;
@property (nonatomic, readwrite) uint64_t downloadedLength;

@end

@implementation BBTTileSourceManager

static NSString *kNorthCampusTileName = @"SCUT3DMap_n.mbtiles";
static NSString *kHEMCCampusTileName = @"SCUT3DMap_s.mbtiles";
static NSString *kTileSourceZipFileName = @"SCUTMbtiles_v1.zip";
static NSString *kTileSourceZipFileMD5 = @"03cb33a5191e090bb483ea7b4bbfbcb3";
static NSString *kSCUTMbtilesZipURL = @"http://bbt.100steps.net/scutmbtilesv1.zip";
//static NSString *kSCUTMbtilesZipURL = @"http://192.168.199.247/scutmbtilesv1.zip";
+ (instancetype)sharedTilesourceManager
{
    static BBTTileSourceManager *_tilesouceManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tilesouceManager = [[BBTTileSourceManager alloc] init];
    });
    
    return _tilesouceManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hasDownloadSession = NO;
        _totalContentSize = 0;
        _downloadedLength = 0;
    }
    return self;
}

- (TCBlobDownloader *)downloader
{
    if (!_downloader) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _downloader = [[TCBlobDownloader alloc] initWithURL:[NSURL URLWithString:kSCUTMbtilesZipURL]
                                               downloadPath:documentsPath
                                              firstResponse:^(NSURLResponse *response) {
                                                  self.downloadState = BBTTileSourceManagerStateDownloading;
                                                  if (self.totalContentSize == 0) { //the total content size has not been set yet.
                                                      NSLog(@"expectedContentLength: %lld", response.expectedContentLength);
                                                      self.totalContentSize = response.expectedContentLength;
                                                  }
                                                  //clear the cache
                                                  NSURLCache * const urlCache = [NSURLCache sharedURLCache];
                                                  const NSUInteger memoryCapacity = urlCache.memoryCapacity;
                                                  urlCache.memoryCapacity = 0;
                                                  urlCache.memoryCapacity = memoryCapacity;
                                                  [self.delegate tilesourceManager:self didReceiveFirstResponse:response];
                                              }
                                                   progress:^(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress) {
                                                       self.downloadState = BBTTileSourceManagerStateDownloading;
                                                       self.downloadedLength = self.totalContentSize - totalLength;
                                                       uint64_t received = self.downloadedLength + receivedLength;
                                                       [self.delegate tilesourceManager:self didReceiveData:received onTotal:self.totalContentSize];
                                                   }
                                                      error:^(NSError *error) {
                                                          self.downloadState = BBTTileSourceManagerStateFailed;
                                                          [self.delegate tilesourceManager:self didStopWithError:error];
                                                      }
                                                   complete:^(BOOL downloadFinished, NSString *pathToFile) {
                                                       if (downloadFinished) {
                                                           self.downloadState = BBTTileSourceManagerStateUnzipping;
                                                           NSLog(@"download finish get called");
                                                           [self.delegate tilesourceManager:self didFinishDownloadWithSucces:YES atPath:pathToFile];
                                                           [self unzipFileAtPath:[NSURL fileURLWithPath:pathToFile]];
                                                           self.hasDownloadSession = NO;
                                                           self.downloadedLength = 0;
                                                       } else {
                                                           self.downloadState = BBTTileSourceManagerStateSuspended;
                                                           [self.delegate tilesourceManager:self didFinishDownloadWithSucces:NO atPath:pathToFile];
                                                       }
                                                   }];
    }
    
    return _downloader;
}

- (void)startDownload
{
    self.downloader = nil;
    [[TCBlobDownloadManager sharedInstance] startDownload:self.downloader];
    self.hasDownloadSession = YES;
    self.downloadState = BBTTileSourceManagerStateDownloading;
}

- (void)cancleDownload
{
    [self.downloader cancelDownloadAndRemoveFile:YES];
    self.downloadedLength = 0;
    self.hasDownloadSession = NO;
}

- (void)suspendDownload
{
    [self.downloader cancelDownloadAndRemoveFile:NO];
    self.downloadState = BBTTileSourceManagerStateSuspended;
}

- (void)removeTileSourceFiles
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *northCampusFile = [documentsPath stringByAppendingPathComponent:kNorthCampusTileName];
    BOOL northCampusFileExists = [[NSFileManager defaultManager] fileExistsAtPath:northCampusFile];
    if (northCampusFileExists) {
        [self removeFileAtPath:[NSURL fileURLWithPath:northCampusFile] withAlertView:nil];
        NSLog(@"remove north campus file done");
    }
    NSString *HEMCCampusFile = [documentsPath stringByAppendingPathComponent:kHEMCCampusTileName];
    BOOL HEMCCampusFileExists = [[NSFileManager defaultManager] fileExistsAtPath:HEMCCampusFile];
    if (HEMCCampusFileExists) {
        [self removeFileAtPath:[NSURL fileURLWithPath:HEMCCampusFile] withAlertView:nil];
        NSLog(@"remove HEMC campus file done");
    }
    NSString *tilesourceZipFile = [documentsPath stringByAppendingPathComponent:kTileSourceZipFileName];
    BOOL tilesourceZipFileExists = [[NSFileManager defaultManager] fileExistsAtPath:tilesourceZipFile];
    if (tilesourceZipFileExists) {
        [self removeFileAtPath:[NSURL fileURLWithPath:tilesourceZipFile] withAlertView:nil];
        NSLog(@"tilesource zip file campus file done");
    }
}

#pragma mark - Utl

- (void)unzipFileAtPath:(NSURL *)filePath
{
    if (!_queue) {
        _queue = dispatch_queue_create("BBTSCUTMbtilesUnZipQueue", NULL);
    }
    
    dispatch_async(_queue,
                   ^ {
                       NSFileManager* fileManager = [NSFileManager defaultManager];
                       NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSURL* path = [NSURL fileURLWithPath:documentsPath];
                       
                       ZZArchive* archive = [ZZArchive archiveWithURL:filePath error:nil];
                       for (ZZArchiveEntry* entry in archive.entries)
                       {
                           NSURL* targetPath = [path URLByAppendingPathComponent:entry.fileName];
                           if (entry.fileMode & S_IFDIR)
                               // check if directory bit is set
                               [fileManager createDirectoryAtURL:targetPath
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:nil];
                           else
                           {
                               // Some archives don't have a separate entry for each directory
                               // and just include the directory's name in the filename.
                               // Make sure that directory exists before writing a file into it.
                               [fileManager createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent]
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:nil];
                               NSError *error;
                               BOOL success = [[entry newDataWithError:nil] writeToURL:targetPath options:NSDataWritingAtomic error:&error];
                               if (success) {
                                   NSLog(@"write to file succeed: %@", targetPath);
                               } else {
                                   NSLog(@"failed to unzip file: %@, %@",entry.fileName, [error localizedDescription]);
                               }
                           }
                       }
                       NSLog(@"unzip done");
                       [self removeFileAtPath:filePath withAlertView:nil];
                       // call delegate method on main thread, to get UI update.
                       dispatch_async(dispatch_get_main_queue(),
                                      ^ {
                                          NSLog(@"download unzipping get called");
                                          self.hasDownloadSession = NO;
                                          NSDictionary *options = @{
                                                                    kCRToastTextKey :@"地图包下载完成",
                                                                    kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                                                    kCRToastBackgroundColorKey : [UIColor BBTSusscessfulGreen],
                                                                    kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                                                    kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                                                    kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                                                    kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                                                                    };
                                          [CRToastManager showNotificationWithOptions:options
                                                                      completionBlock:^{
                                                                          NSLog(@"Completed");
                                                                      }];
                                      });

                       NSLog(@"done async write");
                   });
}

- (void)removeFileAtPath:(NSURL *)path withAlertView:(UIAlertView *)alertView
{
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtURL:path error:&error];
    if (success) {
        NSLog(@"Did delete file -:%@ ",[error localizedDescription]);
        if (alertView && [alertView isKindOfClass:[UIAlertView class]]) {
            [alertView show];
        }
    } else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

+ (RMMBTilesSource *)northCampusTile
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *northCampusFile = [documentsPath stringByAppendingPathComponent:kNorthCampusTileName];
    BOOL northCampusFileExists = [[NSFileManager defaultManager] fileExistsAtPath:northCampusFile];
    if (northCampusFileExists) {
        NSLog(@"2333 exists");
        RMMBTilesSource *northCampusTile = [[RMMBTilesSource alloc] initWithTileSetURL:[NSURL fileURLWithPath:northCampusFile]];
        northCampusTile.cacheable = YES;
        return northCampusTile;
    } else {
        return nil;
    }
}

+ (RMMBTilesSource *)HEMCCampusTile
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *HEMCCampusFile = [documentsPath stringByAppendingPathComponent:kHEMCCampusTileName];
    BOOL HEMCCampusFileExists = [[NSFileManager defaultManager] fileExistsAtPath:HEMCCampusFile];
    if (HEMCCampusFileExists) {
        RMMBTilesSource *HEMCCampusTile = [[RMMBTilesSource alloc] initWithTileSetURL:[NSURL fileURLWithPath:HEMCCampusFile]];
        HEMCCampusTile.cacheable = YES;
        return HEMCCampusTile;
    } else {
        return nil;
    }
}

+ (BOOL)hasDownloadTilesource
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *northCampusFile = [documentsPath stringByAppendingPathComponent:kNorthCampusTileName];
    BOOL northCampusFileExists = [[NSFileManager defaultManager] fileExistsAtPath:northCampusFile];
    NSString *HEMCCampusFile = [documentsPath stringByAppendingPathComponent:kHEMCCampusTileName];
    BOOL HEMCCampusFileExists = [[NSFileManager defaultManager] fileExistsAtPath:HEMCCampusFile];
    return northCampusFileExists && HEMCCampusFileExists;
}

@end
