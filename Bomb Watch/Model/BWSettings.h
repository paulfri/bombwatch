//
//  BWSettings.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/4/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWVideo.h"

@interface BWSettings : NSObject

+ (void)initializeSettings;

+ (BWVideoQuality)defaultQuality;
+ (BOOL)lockRotation;
+ (NSString *)apiKey;

+ (void)setDefaultQuality:(BWVideoQuality)quality;
+ (void)setLockRotation:(BOOL)lockRotation;
+ (void)setAPIKey:(NSString *)key;

+ (BOOL)accountIsLinked;
+ (void)unlinkAccount;

@end
