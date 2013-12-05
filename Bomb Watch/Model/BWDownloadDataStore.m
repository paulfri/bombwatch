//
//  BWDownloadDataStore.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownloadDataStore.h"
#import <tgmath.h>

NSString *const kBWDownloadsFilename = @"bwdownloads";

@interface BWDownloadDataStore ()
@property (strong, nonatomic) NSMutableArray *downloads;
@end

@implementation BWDownloadDataStore

+ (id)defaultStore
{
    static BWDownloadDataStore *defaultStore;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultStore = [[BWDownloadDataStore alloc] init];
        defaultStore.downloads = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.class downloadsFilePath]];
        
        if (!defaultStore.downloads) {
            defaultStore.downloads = [NSMutableArray array];

            for (BWDownload *download in defaultStore.downloads) {
                [download addObserver:defaultStore forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
            }
        }
    });

    return defaultStore;
}

- (NSArray *)allDownloads
{
    return [self.downloads copy];
}

#warning do this!!!
// TODO need a way to occasionally save progress to disk, but not on every notification (lol)
// TODO maybe add [self] as an observer to the download and have that fire off 'save me' notifications?
- (void)addDownload:(BWDownload *)download
{
    [self.downloads addObject:download];
    [download addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self save];
}

- (BWDownload *)downloadForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    for (BWDownload *download in self.downloads) {
        if ([download.video isEqual:video] && download.quality == quality) {
            return download;
        }
    }

    return nil;
}

- (NSArray *)downloadsForVideo:(BWVideo *)video
{
    NSMutableArray *downloads = [NSMutableArray array];

    for (BWDownload *download in self.downloads) {
        if ([download.video isEqual:video]) {
            [downloads addObject:download];
        }
    }
    
    return downloads;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"]) {
        BWDownload *download = (BWDownload *)object;

        // TODO this is saving WAY too often
        [self save];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)deleteDownload:(BWDownload *)download
{
    [[NSFileManager defaultManager] removeItemAtPath:[download.filePath path] error:nil];
    [self.downloads removeObject:download];
    [self save];
}

#pragma mark - utility

+ (NSString *)documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)downloadsFilePath
{
    return [[self documentsPath] stringByAppendingPathComponent:kBWDownloadsFilename];
}

- (void)dealloc
{
    for (BWDownload *download in self.downloads) {
        [download removeObserver:self forKeyPath:@"progress"];
    }
}

- (void)save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"disk access");
        [NSKeyedArchiver archiveRootObject:self.downloads toFile:[self.class downloadsFilePath]];
    });
}

@end
