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
#import "BWDownloadsDataStore.h"
#import "MKiCloudSync.h"

#define PocketConsumerKey @"17866-6c522817c89aaee6ae6da74f"

@implementation BWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window setTintColor:[UIColor colorWithRed:178.0/255 green:34.0/255 blue:34.0/255 alpha:1]];
    [[PocketAPI sharedAPI] setConsumerKey:PocketConsumerKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultPreferences]];

    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    NSString *defaultView = [[NSUserDefaults standardUserDefaults] stringForKey:@"initialView"];

    // custom app launch screen - set in preferences
    if (![defaultView isEqualToString:@"Categories"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UITabBarController *root = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBarVC"];
        self.window.rootViewController = root;
        UINavigationController *nav = (UINavigationController *)root.viewControllers[0];
        [nav.topViewController performSegueWithIdentifier:@"videoListSegue"
                                                   sender:defaultView];
    }
    
    [MKiCloudSync start];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if([[PocketAPI sharedAPI] handleOpenURL:url])
        return YES;
    else
        return NO;
}

- (NSDictionary *)defaultPreferences {
    return @{@"showTrailersInLatest": @YES,
              @"showPremiumInLatest": @NO,
               @"rotationLockVideos": @NO,
                      @"initialView": @"Categories",
                           @"apiKey": GiantBombDefaultAPIKey,
                    @"videosWatched": @[],
                    @"videoProgress": @{}};
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[[BWDownloadsDataStore defaultStore] managedObjectContext] save:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"complete == nil"];
    NSArray *incompletes = [[[BWDownloadsDataStore defaultStore] managedObjectContext] executeFetchRequest:fetchRequest error:nil];

    for (BWDownload *download in incompletes) {
        // TODO: figure out how to save the progress of the download - notification listening?
//        [[BWDownloadsDataStore defaultStore] cancelRequestForDownload:download];
    }

    [[[BWDownloadsDataStore defaultStore] managedObjectContext] save:nil];
}

@end
