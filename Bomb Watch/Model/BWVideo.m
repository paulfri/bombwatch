//
//  BWVideo.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideo.h"
#import "BWVideoDataStore.h"

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
        urlKeys = @[@"siteDetailURL",
                    @"videoMobileURL",
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
    return [[BWVideoDataStore defaultStore] watchedStatusForVideo:self];
}

- (void)setWatched:(BOOL)watchedStatus
{
    [[BWVideoDataStore defaultStore] setWatchedStatus:watchedStatus forVideo:self];
}

- (BOOL)isFavorited
{
    return [[BWVideoDataStore defaultStore] favoriteStatusForVideo:self];
}

- (void)setFavorited:(BOOL)favoritedStatus
{
    [[BWVideoDataStore defaultStore] setFavoriteStatus:favoritedStatus forVideo:self];
}

#pragma mark - utility

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    return self.videoID == ((BWVideo *)object).videoID;
}

@end
