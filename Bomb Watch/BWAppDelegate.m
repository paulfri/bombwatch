//
//  BWAppDelegate.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//
#import "BWAppDelegate.h"
#import "PocketAPI.h"
#import "GiantBombAPIClient.h"
#import <AVFoundation/AVFoundation.h>

#import "BWVideo.h"

#define PocketConsumerKey    @"17866-6c522817c89aaee6ae6da74f"
#define kBWGiantBombRedColor [UIColor colorWithRed:178.0/255 green:34.0/255 blue:34.0/255 alpha:1]

@implementation BWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureInterface];
    [self configureURLCache];
    [self configurePreferences];
    [[PocketAPI sharedAPI] setConsumerKey:PocketConsumerKey];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    NSLog(@"favorites: %d", [[BWVideo favorites] count]);
    
    return YES;
}

- (void)configurePreferences
{
    NSDictionary *defaultPreferences =  @{@"showTrailersInLatest": @NO,
                                                 @"lockRotation": @YES,
                                                  @"initialView": @"Latest",
                                               @"defaultQuality": @"Mobile",
                                                       @"apiKey": GiantBombDefaultAPIKey,
                                                @"videosWatched": @[],
                                                @"videoProgress": @{}};

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
}

- (void)configureURLCache
{
    [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                                diskCapacity:20 * 1024 * 1024
                                                                    diskPath:nil]];
}

- (void)configureInterface
{
    [self.window setTintColor:kBWGiantBombRedColor];
    [[UINavigationBar appearance] setBarTintColor:kBWGiantBombRedColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:kBWGiantBombRedColor];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - App Delegate methods

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if([[PocketAPI sharedAPI] handleOpenURL:url]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        [application endBackgroundTask:backgroundTaskIdentifier];
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Remote control

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BWRemoteControlEventReceived" object:event];
}

@end
