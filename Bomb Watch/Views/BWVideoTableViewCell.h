//
//  BWVideoTableViewCell.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "PDGesturedTableView.h"
#import "BWVideo.h"

@interface BWVideoTableViewCell : PDGesturedTableViewCell

- (void)setFavorited:(BOOL)favoritedStatus animated:(BOOL)animated;
- (void)setWatched:(BOOL)watchedStatus animated:(BOOL)animated;

- (void)setBackgroundImageWithURL:(NSURL *)imageURL;

@end
