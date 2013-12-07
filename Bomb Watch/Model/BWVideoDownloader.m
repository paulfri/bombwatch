//
//  BWVideoDownloader.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoDownloader.h"
#import "GiantBombAPIClient.h"
#import "BWDownload.h"
#import "BWDownloadDataStore.h"

@interface BWVideoDownloader ()
@property (strong, nonatomic) NSMutableArray *downloads;
@property (strong, nonatomic) NSMutableArray *downloadTasks;
@end

@implementation BWVideoDownloader

+ (id)defaultDownloader
{
    static BWVideoDownloader *defaultDownloader;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultDownloader = [[BWVideoDownloader alloc] init];
        defaultDownloader.downloads = [NSMutableArray array];
        defaultDownloader.downloadTasks = [NSMutableArray array];

        [[NSFileManager defaultManager] createDirectoryAtPath:[self videoDirectory]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    });

    return defaultDownloader;
}

- (BWDownload *)downloadVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    BWDownload *download = [[BWDownloadDataStore defaultStore] downloadForVideo:video quality:quality];
    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask;

    NSURL *(^destination)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
        return [self.class localURLForVideo:video quality:quality];
    };

    void (^completionHandler)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
        if ([download isComplete]) {
            [progress removeObserver:download forKeyPath:kBWDownloadProgressKey context:NULL];
            [[BWVideoDownloader defaultDownloader] downloadCompleted:download atFilePath:filePath];
            NSLog(@"Download finished: %@", download.video.name);
        }
    };

    if (!download.resumeData) {
        downloadTask = [[AFHTTPSessionManager manager] downloadTaskWithRequest:[NSURLRequest requestWithURL:[self.class remoteURLForVideo:video quality:quality]]
                                                                      progress:&progress
                                                                   destination:destination
                                                             completionHandler:completionHandler];
    } else {
        downloadTask = [[AFHTTPSessionManager manager] downloadTaskWithResumeData:download.resumeData
                                                                         progress:&progress
                                                                      destination:destination
                                                                completionHandler:completionHandler];
    }

    [progress addObserver:download forKeyPath:kBWDownloadProgressKey options:NSKeyValueObservingOptionNew context:NULL];

    [self.downloads addObject:download];
    [self.downloadTasks addObject:downloadTask];
    [downloadTask resume];

    return download;
}

- (void)downloadCompleted:(BWDownload *)download atFilePath:(NSURL *)filePath
{
    download.filePath = filePath;
    download.resumeData = nil;

    NSUInteger index = [self.downloads indexOfObject:download];
    [self.downloads removeObject:download];
    [self.downloadTasks removeObjectAtIndex:index];

    [[BWDownloadDataStore defaultStore] save];
}

- (NSURLSessionDownloadTask *)downloadTaskForDownload:(BWDownload *)download
{
    return [self.downloadTasks objectAtIndex:[self.downloads indexOfObject:download]];
}

- (void)cancelAllActiveDownloads
{
    for (BWDownload *download in self.downloads) {
        [[BWDownloadDataStore defaultStore] deleteDownload:download];
    }

    [self.downloads removeAllObjects];
    [self.downloadTasks removeAllObjects];
}

- (void)pauseAllActiveDownloads
{
    for (BWDownload *download in self.downloads) {
        [self pauseDownload:download];
    }
}

- (void)pauseDownload:(BWDownload *)download
{
    NSInteger i = [self.downloads indexOfObject:download];
    NSURLSessionDownloadTask *downloadTask = self.downloadTasks[i];

    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        download.resumeData = resumeData;
    }];

    [self.downloads removeObject:download];
    [self.downloadTasks removeObject:downloadTask];
}

- (void)resumeDownload:(BWDownload *)download
{
    [self downloadVideo:download.video quality:download.quality];
}

#pragma mark - Utility

+ (NSURL *)remoteURLForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    switch (quality) {
        case BWVideoQualityMobile:
            return video.videoMobileURL;
        case BWVideoQualityHigh:
            return video.videoHighURL;
        case BWVideoQualityHD:
            return video.videoHDURL;
        case BWVideoQualityLow:
        default:
            return video.videoLowURL;
    }
}

+ (NSURL *)localURLForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    NSURL *remoteURL = [self remoteURLForVideo:video quality:quality];
    NSString *path = [[self videoDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d", video.videoID, quality]];
    NSString *full = [path stringByAppendingPathExtension:[remoteURL pathExtension]];

    return [NSURL fileURLWithPath:full];
}

+ (NSString *)videoDirectory
{
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *vids = [docs stringByAppendingPathComponent:@"videos"];

    return vids;
}

@end
