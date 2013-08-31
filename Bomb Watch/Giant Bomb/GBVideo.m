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

        // this shouldn't be necessary for images of videos, but leaving it in just in case
        if(dictionary[@"image"] != (id)[NSNull null]) {
            self.imageIconURL = [NSURL URLWithString:dictionary[@"image"][@"icon_url"]];
            self.imageMediumURL = [NSURL URLWithString:dictionary[@"image"][@"medium_url"]];
        }

        self.videoLowURL = [NSURL URLWithString:dictionary[@"low_url"]];
        self.videoHighURL = [NSURL URLWithString:dictionary[@"high_url"]];

        if(dictionary[@"hd_url"] != nil)
            self.videoHDURL = [NSURL URLWithString:dictionary[@"hd_url"]];
        else
            self.videoHDURL = [NSURL URLWithString:GiantBombVideoEmptyURL];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.publishDate = [df dateFromString: [dictionary objectForKey:@"publish_date"]];
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
                           @"image":@{@"icon_url": [self.imageIconURL absoluteString], @"medium_url": [self.imageMediumURL absoluteString]},
                           @"low_url":[self.videoLowURL absoluteString],
                           @"high_url":[self.videoHighURL absoluteString],
                           @"hd_url":[self.videoHDURL absoluteString],
                           @"publish_date":[df stringFromDate:self.publishDate]};

    [encoder encodeObject:dict forKey:@"dictionary"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSDictionary *dict = [decoder decodeObjectForKey:@"dictionary"];
    return [self initWithDictionary:dict];
}

@end
