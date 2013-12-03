//
//  BWVideoDownloader.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWDownload.h"

@interface BWVideoDownloader : NSObject

+ (instancetype)defaultDownloader;

- (BWDownload *)downloadVideo:(BWVideo *)video quality:(BWVideoQuality)quality;

@end
