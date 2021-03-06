//
//  BWDownload.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "BWVideo.h"

extern NSString *const kBWDownloadProgressKey;

@interface BWDownload : MTLModel

- (id)initWithVideo:(BWVideo *)video quality:(BWVideoQuality)quality;
- (BOOL)isComplete;
- (BOOL)isInProgress;

@property (strong, nonatomic) BWVideo *video;
@property BWVideoQuality quality;
@property (strong, nonatomic) NSURL *filePath;
@property double progress;

@property (strong, nonatomic) NSData *resumeData;

@end
