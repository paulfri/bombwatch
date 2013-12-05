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

#define kBWDefaultSettingDefaultQuality  @1 // BWDefaultQualityLow
NSString *const kBWDefaultSettingAPIKey  = @"e5ab8850b03bcec7ce6590ca705c9a26395dddf1";
#define kBWDefaultSettingLockRotation    @YES

@implementation BWSettings

+ (void)initializeSettings
{
    NSDictionary *defaultPreferences =  @{kBWSettingsKeyAPIKey : kBWDefaultSettingAPIKey,
                                          kBWSettingsKeyDefaultQuality : kBWDefaultSettingDefaultQuality,
                                          kBWSettingsKeyLockRotation : kBWDefaultSettingLockRotation,
                                          @"videosWatched": @[],
                                          @"videoProgress": @{}};

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

#pragma mark - misc

+ (BOOL)accountIsLinked
{
    return ![[self apiKey] isEqualToString:kBWDefaultSettingAPIKey];
}

+ (void)unlinkAccount
{
    [[NSUserDefaults standardUserDefaults] setObject:kBWDefaultSettingAPIKey forKey:kBWSettingsKeyAPIKey];
}

@end
