//
//  BWVideoDataStore.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/1/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWVideo.h"

extern NSString *const kBWFavoritesKey;
extern NSString *const kBWCacheFilePrefix;

@interface BWVideoDataStore : NSObject

+ (instancetype)defaultStore;

- (BWVideo *)videoWithID:(NSInteger)videoID inCategory:(NSString *)category;

- (NSArray *)cachedVideosForCategory:(NSString *)category;
- (void)setCachedVideos:(NSArray *)videos forCategory:(NSString *)category;
- (void)refreshAllCaches;

- (NSMutableArray *)favorites;
- (void)setFavorites:(NSArray *)favorites;
- (BOOL)favoriteStatusForVideo:(BWVideo *)video;
- (void)setFavoriteStatus:(BOOL)status forVideo:(BWVideo *)video;

+ (NSString *)documentsPath;

@end
