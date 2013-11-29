//
//  BWVideoPlayerViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 9/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "GBVideo.h"
#import "BWVideoPlayerDelegate.h"

@interface BWVideoPlayerViewController : MPMoviePlayerViewController

@property (strong, nonatomic) GBVideo *video;
@property (strong, nonatomic) NSNumber *quality;
@property (weak) id<BWVideoPlayerDelegate> delegate;

- (id)initWithVideo:(GBVideo *)video;

- (id)initWithVideo:(GBVideo *)video
            quality:(NSInteger)quality
          downloads:(NSArray *)downloads;

- (void)play;

@end
