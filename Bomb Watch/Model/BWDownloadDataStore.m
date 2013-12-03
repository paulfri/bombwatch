//
//  BWDownloadDataStore.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownloadDataStore.h"

NSString *const kBWDownloadsFilename = @"bwdownloads";

@implementation BWDownloadDataStore

+ (id)defaultStore
{
    static BWDownloadDataStore *defaultStore;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultStore = [[BWDownloadDataStore alloc] init];
    });

    return defaultStore;
}

#warning do this
- (void)addDownload:(BWDownload *)download
{

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

@end
