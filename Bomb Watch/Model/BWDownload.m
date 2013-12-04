//
//  BWDownload.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownload.h"

NSString *const kBWDownloadProgressKey = @"fractionCompleted";

@implementation BWDownload

- (id)initWithVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    self = [super init];

    if (self) {
        self.video = video;
        self.quality = quality;
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:kBWDownloadProgressKey]) {
        NSProgress *progress = (NSProgress *)object;
        self.progress = progress.fractionCompleted;
        [self setValue:progress forKey:kBWDownloadProgressKey];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)isComplete
{
    return self.progress >= 1.0;
}

@end
