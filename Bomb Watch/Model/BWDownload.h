//
//  BWDownload.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "BWVideo.h"

@interface BWDownload : MTLModel

@property (strong, nonatomic) BWVideo *video;
@property BWVideoQuality quality;
@property double progress;

@end
