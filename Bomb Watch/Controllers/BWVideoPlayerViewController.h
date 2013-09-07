//
//  BWVideoPlayerViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 9/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "GBVideo.h"

@interface BWVideoPlayerViewController : MPMoviePlayerViewController

@property (strong, nonatomic) GBVideo *video;
@property NSNumber *quality;

- (id)initWithVideo:(GBVideo *)video;

- (id)initWithVideo:(GBVideo *)video
            quality:(NSInteger)quality
          downloads:(NSArray *)downloads;

- (void)play;

@end
