//
//  BWVideoSelectionDelegate.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/9/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWVideo.h"

@protocol BWVideoSelectionDelegate <NSObject>

@required
- (void)selectedVideo:(BWVideo *)video;

@end
