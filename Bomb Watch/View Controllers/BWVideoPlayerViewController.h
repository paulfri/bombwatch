//
//  BWVideoPlayerViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 9/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "BWVideo.h"

@protocol BWVideoPlayerDelegate <NSObject>

- (void)videoDidFinishPlaying;

@end

@interface BWVideoPlayerViewController : MPMoviePlayerViewController

- (id)initWithVideo:(BWVideo *)video;
- (id)initWithVideo:(BWVideo *)video quality:(BWVideoQuality)quality;

@property (strong, nonatomic) BWVideo *video;
@property BWVideoQuality quality;
@property (weak) id<BWVideoPlayerDelegate> delegate;

- (void)play;

@end
