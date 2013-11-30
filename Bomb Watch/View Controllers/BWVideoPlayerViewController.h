//
//  BWVideoPlayerViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 9/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "BWVideo.h"
#import "BWVideoPlayerDelegate.h"

@interface BWVideoPlayerViewController : MPMoviePlayerViewController

@property (strong, nonatomic) BWVideo *video;
@property (strong, nonatomic) NSNumber *quality;
@property (weak) id<BWVideoPlayerDelegate> delegate;

- (id)initWithVideo:(BWVideo *)video;

- (id)initWithVideo:(BWVideo *)video
            quality:(NSInteger)quality
          downloads:(NSArray *)downloads;

- (void)play;

@end
