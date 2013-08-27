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
        self.videoHDURL = [NSURL URLWithString:[dictionary objectForKey:@"hd_url"]];
        // this one is a relative path -- not sure what to do with it
        // self.videoURL = [NSURL URLWithString:[dictionary objectForKey:@"url"]];
    }

    return self;
}

@end
