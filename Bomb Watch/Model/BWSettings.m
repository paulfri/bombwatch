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

#define kBWDefaultSettingDefaultQuality  @2 // BWVideoQualityHigh
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
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:kBWSettingsKeyWatchComplete] containsObject:[NSNumber numberWithInt:video.videoID]];
}

+ (NSTimeInterval)progressForVideo:(BWVideo *)video
{
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress] allKeys] containsObject:[NSNumber numberWithInt:video.videoID]]) {
        return 0.0f;
    }

    return [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress][[NSNumber numberWithInt:video.videoID]] doubleValue];
}

#pragma mark - setters

+ (void)setDefaultQuality:(BWVideoQuality)quality
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:quality] forKey:kBWSettingsKeyDefaultQuality];
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
    if (![watched containsObject:video]) {
        [[NSUserDefaults standardUserDefaults] setObject:[watched arrayByAddingObject:video] forKey:kBWSettingsKeyWatchComplete];
    }
}

+ (void)removeWatchedVideo:(BWVideo *)video
{
    NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:kBWSettingsKeyWatchComplete] mutableCopy];
    if ([watched containsObject:video]) {
        [watched removeObject:video];
    }

    [[NSUserDefaults standardUserDefaults] setObject:watched forKey:kBWSettingsKeyWatchComplete];
}

+ (void)removeWatchedProgressForVideo:(BWVideo *)video
{
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress] mutableCopy];
    NSNumber *key = [NSNumber numberWithInteger:video.videoID];
    if ([[dict allKeys] containsObject:key]) {
        [dict removeObjectForKey:key];
    }

    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBWSettingsKeyWatchProgress];
}

+ (void)setWatchedProgress:(NSTimeInterval)progress forVideo:(BWVideo *)video
{
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBWSettingsKeyWatchProgress] mutableCopy];
    NSNumber *key = [NSNumber numberWithInteger:video.videoID];
    dict[key] = [NSNumber numberWithDouble:progress];

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
