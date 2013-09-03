//
//  GBVideo.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "GBVideo.h"


@implementation GBVideo

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.videoID = [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
        self.name = dictionary[@"name"];
        self.summary = dictionary[@"deck"];
        self.user = dictionary[@"user"];
        
        // this shouldn't be necessary for images of videos, but leaving it in just in case
        if(dictionary[@"image"] != nil && dictionary[@"image"] != (id)[NSNull null]) {
            self.imageIconURL = [NSURL URLWithString:dictionary[@"image"][@"icon_url"]];
            self.imageMediumURL = [NSURL URLWithString:dictionary[@"image"][@"medium_url"]];
        }

        NSString *mobileURLString = [((NSString *)dictionary[@"low_url"]) stringByReplacingOccurrencesOfString:@"_800"
                                                                                                    withString:@".ipod"];
        self.videoMobileURL = [NSURL URLWithString:mobileURLString];
        self.videoLowURL = [NSURL URLWithString:dictionary[@"low_url"]];
        self.videoHighURL = [NSURL URLWithString:dictionary[@"high_url"]];

        if(dictionary[@"hd_url"] != nil) {
            NSString *hdURL = [NSString stringWithFormat:@"%@%@%@", (NSString *)dictionary[@"hd_url"], @"&api_key=", [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"]];
            self.videoHDURL = [NSURL URLWithString:hdURL];
        } else
            self.videoHDURL = [NSURL URLWithString:GiantBombVideoEmptyURL];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.publishDate = [df dateFromString: [dictionary objectForKey:@"publish_date"]];
        
        self.siteDetailURL = [NSURL URLWithString:dictionary[@"site_detail_url"]];
        self.lengthInSeconds = dictionary[@"length_seconds"];
    }

    return self;
}

#pragma mark - NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDictionary *dict = @{@"id": self.videoID,
                           @"name":self.name,
                           @"deck":self.summary,
                           @"user":self.user,
                           @"image":@{@"icon_url": [self.imageIconURL absoluteString], @"medium_url": [self.imageMediumURL absoluteString]},
                           @"low_url":[self.videoLowURL absoluteString],
                           @"high_url":[self.videoHighURL absoluteString],
                           @"hd_url":[self.videoHDURL absoluteString],
                           @"publish_date":[df stringFromDate:self.publishDate],
                           @"site_detail_url":[self.siteDetailURL absoluteString],
                           @"length_seconds":self.lengthInSeconds};

    [encoder encodeObject:dict forKey:@"dictionary"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSDictionary *dict = [decoder decodeObjectForKey:@"dictionary"];
    return [self initWithDictionary:dict];
}

#pragma mark - watch status

- (BOOL)isWatched {
    NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"videosWatched"] mutableCopy];
    return [array containsObject:self.videoID];
}

- (void)setWatched {
    NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"videosWatched"] mutableCopy];
    if (![array containsObject:self.videoID]) {
        [array addObject:self.videoID];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[array copy] forKey:@"videosWatched"];
}

- (void)setUnwatched {
    NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"videosWatched"] mutableCopy];
    if ([array containsObject:self.videoID]) {
        [array removeObject:self.videoID];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[array copy] forKey:@"videosWatched"];
}

@end
