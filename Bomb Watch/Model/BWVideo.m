//
//  BWVideo.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideo.h"
#import "BWVideoDataStore.h"
#import "BWSettings.h"

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
                    @"videoLowURL",
                    @"videoHighURL",
                    @"imageIconURL",
                    @"imageSmallURL",
                    @"imageMediumURL"];
    }
    
    if ([urlKeys containsObject:key]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    } else if ([key isEqualToString:@"videoHDURL"]) {
        return [MTLValueTransformer reversibleTransformerWithBlock:^NSString *(NSString *hdURL) {
            if (!hdURL) return nil;
            return [NSURL URLWithString:[hdURL stringByAppendingPathComponent:[NSString stringWithFormat:@"&api_key=%@", [BWSettings apiKey]]]];
       }];
    }
    
    return nil;
}

#pragma mark - hackish custom getters

- (NSURL *)videoMobileURL
{
    if (!self.videoLowURL) return nil;
    return [NSURL URLWithString:[[self.videoLowURL absoluteString] stringByReplacingOccurrencesOfString:@"_800" withString:@".ipod"]];
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

#pragma mark - category lists

+ (NSArray *)categories
{
    return @[@"Latest", @"Quick Looks", @"Features", @"Events", @"Endurance Run", @"TANG", @"Reviews", @"Trailers", @"Subscriber"];
}

+ (NSArray *)enduranceRunCategories
{
    return @[@"Persona 4", @"The Matrix Online", @"Deadly Premonition", @"Chrono Trigger"];
}

+ (NSString *)categoryIDForCategory:(NSString *)category
{
    NSDictionary *map = [NSDictionary dictionaryWithObjects:@[@"0", @"3", @"8", @"6", @"5", @"4", @"2", @"7", @"10"]
                                                    forKeys:[self categories]];

    return map[category];
}

#pragma mark - utility

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    return self.videoID == ((BWVideo *)object).videoID;
}

@end
