//
//  BWVideo.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideo.h"

static NSString *kBWDefaultsFavoritesKey = @"favoritedVideos";
static NSString *kBWDefaultsWatchedKey   = @"videosWatched";

@implementation BWVideo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"videoID": @"id",
             @"name": @"name",
             @"summary": @"deck",
             @"siteDetailURL": @"site_detail_url",
             @"length": @"length_seconds",
             @"date": @"publish_date",
             @"user": @"user",
             @"videoType": @"video_type",
             @"videoMobileURL": NSNull.null, // TODO fix me
             @"videoLowURL": @"low_url",
             @"videoHighURL": @"high_url",
             @"videoHDURL": @"hd_url",
             @"imageIconURL": @"image.icon_url",
             @"imageSmallURL": @"image.small_url",
             @"imageMediumURL": @"image.medium_url"};
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key
{
    static NSArray *urlKeys;
    
    if (urlKeys == nil) {
        urlKeys = @[@"videoMobileURL",
                    @"videoLowURL",
                    @"videoHighURL",
                    @"videoHDURL",
                    @"imageIconURL",
                    @"imageSmallURL",
                    @"imageMediumURL"];
    }
    
    if ([urlKeys containsObject:key]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    
    return nil;
}

#pragma mark - watch status

- (BOOL)isWatched
{
    NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:kBWDefaultsWatchedKey] mutableCopy];
    return [watched containsObject:[NSNumber numberWithInt:self.videoID]];
}

- (void)setWatched:(BOOL)watchedStatus
{
    NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:kBWDefaultsWatchedKey] mutableCopy];
    NSNumber *videoID = [NSNumber numberWithInt:self.videoID];
    
    if (watchedStatus && ![watched containsObject:videoID]) {
        [watched addObject:videoID];
    } else if ([watched containsObject:videoID]) {
        [watched removeObject:videoID];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[watched copy] forKey:kBWDefaultsWatchedKey];
}

- (BOOL)isFavorited
{
    return [[self.class favorites] containsObject:self];
}

- (void)setFavorited:(BOOL)favoritedStatus
{
    NSMutableArray *favorites = [self.class favorites];
    
    if (favoritedStatus && ![favorites containsObject:self]) {
        [favorites addObject:self];
    } else if ([favorites containsObject:self]) {
        [favorites removeObject:self];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:favorites]
                                              forKey:kBWDefaultsFavoritesKey];
}

- (UIColor *)cellTextColor
{
    if ([self isWatched]) {
        return [UIColor grayColor];
    }
    
    return [UIColor whiteColor];
}

#pragma mark - utility

+ (NSMutableArray *)favorites
{
    NSData *favoritedData    = [[NSUserDefaults standardUserDefaults] objectForKey:kBWDefaultsFavoritesKey];
    NSMutableArray *favorites;
    
    if (favoritedData)
    {
        NSArray *favoritedVideosArray = [NSKeyedUnarchiver unarchiveObjectWithData:favoritedData];
        if (favoritedVideosArray) {
            favorites = [[NSMutableArray alloc] initWithArray:favoritedVideosArray];
        } else {
            favorites = [NSMutableArray array];
        }
    }

    return favorites;
}

@end
