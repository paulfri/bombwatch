//
//  BWVideo.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideo.h"

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
                    @"imageMediumURL"];
    }
    
    if ([urlKeys containsObject:key]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    
    return nil;
}

#pragma mark - watch status

- (BOOL)isWatched {
    NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"videosWatched"] mutableCopy];
    return [watched containsObject:[NSNumber numberWithInt:self.videoID]];
}

- (void)setWatched:(BOOL)watchedStatus {
    NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"videosWatched"] mutableCopy];
    NSNumber *videoID = [NSNumber numberWithInt:self.videoID];
    
    if (watchedStatus && ![watched containsObject:videoID]) {
        [watched addObject:videoID];
    } else if ([watched containsObject:videoID]) {
        [watched removeObject:videoID];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[watched copy] forKey:@"videosWatched"];
}

#warning break this out into a category
- (UIColor *)cellTextColor
{
    if ([self isWatched]) {
        return [UIColor grayColor];
    }
    
    return [UIColor whiteColor];
}

@end
