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
#import "BWPushNotificationClient.h"
#import "BWVideoFetcher.h"
#import "BWVideoDataStore.h"

#define PocketConsumerKey    @"17866-6c522817c89aaee6ae6da74f"
#define kBWGiantBombRedColor [UIColor colorWithRed:178.0/255 green:34.0/255 blue:34.0/255 alpha:1]
#define kBWGiantBombCharcoalColor [UIColor colorWithRed:34.0/255 green:34.0/255 blue:34.0/255 alpha:1.0]

@implementation BWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureInterface];
    [self configureURLCache];
    [self configurePreferences];
    [[PocketAPI sharedAPI] setConsumerKey:PocketConsumerKey];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
       (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [self openVideoWithNotification:notification];
    }

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
    [[UISwitch appearance] setOnTintColor:kBWGiantBombRedColor];
    [[UITableViewCell appearance] setBackgroundColor:[UIColor darkGrayColor]];
    [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    [[UILabel appearanceWhenContainedIn:UISearchBar.class, nil] setTextColor:[UIColor blackColor]];
    [[UILabel appearanceWhenContainedIn:UITextField.class, nil] setTextColor:[UIColor lightGrayColor]];
    [[UIToolbar appearance] setBarTintColor:kBWGiantBombCharcoalColor];
    [[UITableView appearance] setBackgroundColor:kBWGiantBombCharcoalColor];
    [[UISearchBar appearance] setBarTintColor:kBWGiantBombCharcoalColor];
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

#pragma mark - Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"APNS token: %@", deviceToken);
    [[BWPushNotificationClient defaultClient] registerForPushNotificationsWithToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"APNS registration error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        // opening the app from the push notification, so go to the selected video
        // TODO is this a race condition?
        NSLog(@"opening from didReceiveRemoteNotification");
        [self openVideoWithNotification:userInfo];
    } else {
        // updates the latest videos cache, both when the app is running and when it is backgrounded
        [self fetchLatestWithCompletionHandler:completionHandler];
    }
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self fetchLatestWithCompletionHandler:completionHandler];
}

- (void)fetchLatestWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[BWVideoFetcher defaultFetcher] fetchVideosForCategory:@"Latest"
                                               searchString:nil
                                                       page:1
                                                    success:^(NSArray *success)
     {
         // TODO (potentially) navigate to video list to update UI snapshot
         completionHandler(UIBackgroundFetchResultNewData);
     }
                                                    failure:^(NSError *error)
     {
         NSLog(@"%@", error);
         completionHandler(UIBackgroundFetchResultFailed);
     }];
}

#pragma mark - Navigation

- (void)openVideoWithNotification:(NSDictionary *)notification
{
    NSInteger videoID = [notification[@"video"] integerValue];
    BWVideo *video = [[BWVideoDataStore defaultStore] videoWithID:videoID inCategory:@"Latest"];

    if (video) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hey duder!" message:[NSString stringWithFormat:@"Totally going to load %@!", video.name] delegate:nil cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
