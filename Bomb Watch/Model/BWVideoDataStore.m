//
//  BWVideoDataStore.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/1/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoDataStore.h"
#import "NSString+Extensions.h"

NSString *const kBWFavoritesKey = @"favorites";
NSString *const kBWCacheFilePrefix   = @"bwcache";

@interface BWVideoDataStore ()
@property (strong, nonatomic) NSMutableDictionary *categories;
@end

@implementation BWVideoDataStore

+ (id)defaultStore
{
    static BWVideoDataStore *defaultStore;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultStore = [[BWVideoDataStore alloc] init];
        defaultStore.categories = [NSMutableDictionary dictionary];
    });

    return defaultStore;
}

- (BWVideo *)videoWithID:(NSInteger)videoID inCategory:(NSString *)category
{
    NSArray *videos = [self cachedVideosForCategory:category];

    for (BWVideo *video in videos) {
        if (video.videoID == videoID) {
            return video;
        }
    }

    return nil;
}

#pragma mark - Caches

- (NSArray *)cachedVideosForCategory:(NSString *)category
{
    if (!self.categories[category]) {
        NSArray *vids = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.class cacheFilePathForCategory:category]];

        if (vids) {
            self.categories[category] = vids;
            return self.categories[category];
        } else {
            return [[NSArray alloc] init];
        }
    }

    return self.categories[category];
}

- (void)setCachedVideos:(NSArray *)videos forCategory:(NSString *)category
{
    self.categories[category] = videos;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        NSLog(@"saving %d videos to the cache for %@", videos.count, category);
        [NSKeyedArchiver archiveRootObject:videos toFile:[self.class cacheFilePathForCategory:category]];
    });
}

- (void)refreshAllCaches
{
    for (NSString *category in [BWVideo categories]) {
        [self setCachedVideos:@[] forCategory:category];
    }
}

#pragma mark - Favorites

- (NSMutableArray *)favorites
{
    return [[self cachedVideosForCategory:kBWFavoritesKey] mutableCopy];
}

- (void)setFavorites:(NSArray *)favorites
{
    [self setCachedVideos:favorites forCategory:kBWFavoritesKey];
}

- (BOOL)favoriteStatusForVideo:(BWVideo *)video
{
    return [self.favorites containsObject:video];
}

- (void)setFavoriteStatus:(BOOL)status forVideo:(BWVideo *)video
{
    NSMutableArray *favorites = [self favorites];

    if (status && ![favorites containsObject:video]) {
        [favorites addObject:video];
    } else if ([favorites containsObject:video]) {
        [favorites removeObject:video];
    }

    [self setFavorites:favorites];
}

#pragma mark - Watched status
#warning implement watched status

- (BOOL)watchedStatusForVideo:(BWVideo *)video
{
    return NO;
}

- (void)setWatchedStatus:(BOOL)status forVideo:(BWVideo *)video
{

}

#pragma mark - Utility

+ (NSString *)documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)cacheFilePathForCategory:(NSString *)category;
{
    NSString *file = [[[category stringByTrimmingWhitespaceCharacters] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kBWCacheFilePrefix, file]];
}

@end
