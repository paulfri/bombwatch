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
    });

    return defaultDownloader;
}

- (BWDownload *)downloadVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    BWDownload *download = [[BWDownload alloc] initWithVideo:video quality:quality];

    NSURL *url = [self.class remoteURLForVideo:video quality:quality];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSProgress *progress;

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:&progress
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
        return [self.class localURLForVideo:video quality:quality];
    }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
        [progress removeObserver:download forKeyPath:kBWDownloadProgressKey context:NULL];
        [[BWVideoDownloader defaultDownloader] downloadCompleted:download atFilePath:filePath];
        NSLog(@"Download finished: %@", download.video.name);
    }];

    [progress addObserver:download forKeyPath:kBWDownloadProgressKey options:NSKeyValueObservingOptionNew context:NULL];

    [self.downloads addObject:download];
    [self.downloadTasks addObject:downloadTask];
    [downloadTask resume];

    return download;
}

- (void)downloadCompleted:(BWDownload *)download atFilePath:(NSURL *)filePath
{
    download.filePath = filePath;
    NSUInteger index = [self.downloads indexOfObject:download];
    [self.downloads removeObject:download];
    [self.downloadTasks removeObjectAtIndex:index];
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

#pragma mark - Utility

+ (NSURL *)remoteURLForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    switch (quality) {
        case BWVideoQualityMobile:
            return video.videoMobileURL; break;
        case BWVideoQualityHigh:
            return video.videoHighURL; break;
        case BWVideoQualityHD:
            return video.videoHDURL; break;
        case BWVideoQualityLow:
        default:
            return video.videoLowURL;
    }
}

+ (NSURL *)localURLForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *vids = [docs stringByAppendingPathComponent:@"videos"]; // TODO create directory
    NSString *path = [vids stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d", video.videoID, quality]];
    NSLog(@"path: %@", path); // TODO add file ext?

    return [NSURL URLWithString:path];
}

@end
