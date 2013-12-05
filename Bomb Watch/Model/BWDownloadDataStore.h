//
//  BWDownloadDataStore.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWDownload.h"

extern NSString *const kBWDownloadsFilename;

@interface BWDownloadDataStore : NSObject

+ (instancetype)defaultStore;

- (NSArray *)allDownloads;
- (void)addDownload:(BWDownload *)download;
- (void)deleteDownload:(BWDownload *)download;

- (BWDownload *)downloadForVideo:(BWVideo *)video quality:(BWVideoQuality)quality;
- (NSArray *)downloadsForVideo:(BWVideo *)video;

- (void)save;

@end
