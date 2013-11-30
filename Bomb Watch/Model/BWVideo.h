//
//  BWVideo.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface BWVideo : MTLModel <MTLJSONSerializing>

@property (assign, nonatomic) NSInteger videoID;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *siteDetailURL;

@property (assign, nonatomic) NSInteger length;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSURL *videoMobileURL;
@property (strong, nonatomic) NSURL *videoLowURL;
@property (strong, nonatomic) NSURL *videoHighURL;
@property (strong, nonatomic) NSURL *videoHDURL;

@property (strong, nonatomic) NSURL *imageIconURL;   // 1:1
@property (strong, nonatomic) NSURL *imageMediumURL; // 16:9

- (BOOL)isWatched;
- (void)setWatched:(BOOL)watchedStatus;

- (UIColor *)cellTextColor;

@end
