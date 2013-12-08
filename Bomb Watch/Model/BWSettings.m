//
//  BWSettings.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/4/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWSettings.h"

NSString *const kBWSettingsKeyDefaultQuality = @"kBWSettingsKeyDefaultQuality";
NSString *const kBWSettingsKeyAPIKey = @"kBWSettingsKeyAPIKey";
NSString *const kBWSettingsKeyLockRotation = @"kBWSettingsKeyLockRotation";
NSString *const kBWSettingsKeyiCloudSync = @"kBWSettingsKeyiCloudSync";
NSString *const kBWSettingsKeyWatchComplete = @"kBWSettingsKeyWatchComplete";
NSString *const kBWSettingsKeyWatchProgress = @"kBWSettingsKeyWatchProgress";

#define kBWDefaultSettingDefaultQuality  @(BWVideoQualityHigh)
NSString *const kBWDefaultSettingAPIKey  = @"e5ab8850b03bcec7ce6590ca705c9a26395dddf1";
#define kBWDefaultSettingLockRotation    @YES
#define kBWDefaultSettingsiCloudSync     @NO
#define kBWDefaultSettingsWatchComplete  @[]
#define kBWDefaultSettingsWatchProgress  @{}

@implementation BWSettings

+ (void)initializeSettings
{
    NSDictionary *defaultPreferences =  @{kBWSettingsKeyAPIKey : kBWDefaultSettingAPIKey,
                                  kBWSettingsKeyDefaultQuality : kBWDefaultSettingDefaultQuality,
                                    kBWSettingsKeyLockRotation : kBWDefaultSettingLockRotation,
                                      kBWSettingsKeyiCloudSync : kBWDefaultSettingsiCloudSync,
                                   kBWSettingsKeyWatchComplete : kBWDefaultSettingsWatchComplete,
                                   kBWSettingsKeyWatchProgress : kBWDefaultSettingsWatchProgress};

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
}

#pragma mark - getters

+ (BWVideoQuality)defaultQuality
{
    NSNumber *quality = [[NSUserDefaults standardUserDefaults] objectForKey:kBWSettingsKeyDefaultQuality];
    return [quality intValue];
}

+ (BOOL)lockRotation
{
    NSNumber *lock = [[NSUserDefaults standardUserDefaults] objectForKey:kBWSettingsKeyLockRotation];
    return [lock boolValue];
}

+ (NSString *)apiKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kBWSettingsKeyAPIKey];
}

+ (BOOL)watchedVideo:(BWVideo *)video
{
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:kBWSettingsKeyWatchComplete] containsObject:@(video.videoID)];
}

+ (NSTimeInterval)progressForVideo:(BWVideo *)video
{
    return [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress][[@(video.videoID) stringValue]] doubleValue];
}

#pragma mark - setters

+ (void)setDefaultQuality:(BWVideoQuality)quality
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:quality] forKey:kBWSettingsKeyDefaultQuality];
}

+ (void)setLockRotation:(BOOL)lockRotation
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:lockRotation] forKey:kBWSettingsKeyLockRotation];
}

+ (void)setAPIKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:kBWSettingsKeyAPIKey];
}

+ (void)addWatchedVideo:(BWVideo *)video
{
    NSArray *watched = [[NSUserDefaults standardUserDefaults] arrayForKey:kBWSettingsKeyWatchComplete];

    if (![watched containsObject:@(video.videoID)]) {
        [[NSUserDefaults standardUserDefaults] setObject:[watched arrayByAddingObject:@(video.videoID)] forKey:kBWSettingsKeyWatchComplete];
    }
}

+ (void)removeWatchedVideo:(BWVideo *)video
{
    NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:kBWSettingsKeyWatchComplete] mutableCopy];

    if ([watched containsObject:@(video.videoID)]) {
        [watched removeObject:@(video.videoID)];
    }

    [[NSUserDefaults standardUserDefaults] setObject:watched forKey:kBWSettingsKeyWatchComplete];
}

+ (void)removeWatchedProgressForVideo:(BWVideo *)video
{
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress] mutableCopy];

    if ([[dict allKeys] containsObject:[@(video.videoID) stringValue]]) {
        [dict removeObjectForKey:[@(video.videoID) stringValue]];
    }

    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBWSettingsKeyWatchProgress];
}

+ (void)setWatchedProgress:(NSTimeInterval)progress forVideo:(BWVideo *)video
{
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress] mutableCopy];
    dict[[@(video.videoID) stringValue]] = @(progress);

    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBWSettingsKeyWatchProgress];
}

#pragma mark - Account linkage

+ (BOOL)accountIsLinked
{
    return ![[self apiKey] isEqualToString:kBWDefaultSettingAPIKey];
}

+ (void)unlinkAccount
{
    [[NSUserDefaults standardUserDefaults] setObject:kBWDefaultSettingAPIKey forKey:kBWSettingsKeyAPIKey];
}

@end
