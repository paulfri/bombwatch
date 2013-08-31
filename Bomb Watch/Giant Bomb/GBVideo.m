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
        self.videoID = [NSNumber numberWithInt:[[dictionary objectForKey:@"id"] intValue]];
        self.name = [dictionary objectForKey:@"name"];
        self.summary = [dictionary objectForKey:@"deck"];

        // this shouldn't be necessary for images of videos, but leaving it in just in case
        if([dictionary objectForKey:@"image"] != (id)[NSNull null]) {
            self.imageIconURL = [NSURL URLWithString:[[dictionary objectForKey:@"image"] objectForKey:@"icon_url"]];
            self.imageMediumURL = [NSURL URLWithString:[[dictionary objectForKey:@"image"] objectForKey:@"medium_url"]];
        }

        self.videoLowURL = [NSURL URLWithString:[dictionary objectForKey:@"low_url"]];
        self.videoHighURL = [NSURL URLWithString:[dictionary objectForKey:@"high_url"]];
//        self.videoHDURL = [NSURL URLWithString:[dictionary objectForKey:@"hd_url"]];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.publishDate = [df dateFromString: [dictionary objectForKey:@"publish_date"]];
        // this one is a relative path -- not sure what to do with it
        // self.videoURL = [NSURL URLWithString:[dictionary objectForKey:@"url"]];
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
//                           @"hd_url":self.videoHDURL,
                           @"publish_date":[df stringFromDate:self.publishDate]};

    [encoder encodeObject:dict forKey:@"dictionary"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSDictionary *dict = [decoder decodeObjectForKey:@"dictionary"];
    return [self initWithDictionary:dict];
}

@end
