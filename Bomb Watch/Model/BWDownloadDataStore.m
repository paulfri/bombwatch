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
        defaultStore.downloads = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self.class downloadsFilePath]] mutableCopy];

        if (!defaultStore.downloads) {
            defaultStore.downloads = [NSMutableArray array];
            [defaultStore save];
        } else {
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

- (void)addDownload:(BWDownload *)download
{
    [self.downloads addObject:download];
    [download addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self save];
}

- (BOOL)downloadExistsForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    return [self.downloads containsObject:[[BWDownload alloc] initWithVideo:video quality:quality]];
}

- (BWDownload *)downloadForVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    for (BWDownload *download in self.downloads) {
        if ([download.video isEqual:video] && download.quality == quality) {
            return download;
        }
    }

    BWDownload *download = [[BWDownload alloc] initWithVideo:video quality:quality];
    [self.downloads addObject:download];

    return download;
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
//        [self save];
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
    [NSKeyedArchiver archiveRootObject:[self.downloads copy] toFile:[self.class downloadsFilePath]];
}

@end
