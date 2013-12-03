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

@implementation BWVideoDownloader

+ (id)defaultDownloader
{
    static BWVideoDownloader *defaultDownloader;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultDownloader = [[BWVideoDownloader alloc] init];
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
        [progress removeObserver:download
                      forKeyPath:kBWDownloadProgressKey
                         context:NULL];
        NSLog(@"Download finished: %@", download.video.name);
    }];

    download.filePath = [self.class localURLForVideo:video quality:quality];

    [progress addObserver:download
               forKeyPath:kBWDownloadProgressKey
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    [downloadTask resume];

    return download;
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
    NSString *vids = [docs stringByAppendingPathComponent:@"videos"];
    NSString *path = [vids stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d", video.videoID, quality]];
    NSLog(@"path: %@", path); // TODO add file ext?

    return [NSURL URLWithString:path];
}

@end
