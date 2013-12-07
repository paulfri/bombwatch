//
//  BWVideo.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Mantle/Mantle.h>

typedef NS_ENUM(NSUInteger, BWVideoQuality) {
    BWVideoQualityMobile,
    BWVideoQualityLow,
    BWVideoQualityHigh,
    BWVideoQualityHD
};

@interface BWVideo : MTLModel <MTLJSONSerializing>

@property (assign, nonatomic) NSInteger videoID;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *siteDetailURL;

@property (assign, nonatomic) NSInteger length;
@property (strong, nonatomic) NSDate *date;
@property (copy, nonatomic) NSString *user;
@property (copy, nonatomic) NSString *type;

@property (strong, nonatomic) NSURL *videoMobileURL;
@property (strong, nonatomic) NSURL *videoLowURL;
@property (strong, nonatomic) NSURL *videoHighURL;
@property (strong, nonatomic) NSURL *videoHDURL;

@property (strong, nonatomic) NSURL *imageIconURL;   // 1:1
@property (strong, nonatomic) NSURL *imageSmallURL;  // 16:9
@property (strong, nonatomic) NSURL *imageMediumURL; // 16:9

- (BOOL)isWatched;
- (void)setWatched:(BOOL)watchedStatus;

- (BOOL)isFavorited;
- (void)setFavorited:(BOOL)favoritedStatus;

+ (NSArray *)categories;
+ (NSArray *)enduranceRunCategories;
+ (NSString *)categoryIDForCategory:(NSString *)category;

@end
