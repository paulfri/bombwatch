//
//  PocketAPIActivity.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "PocketAPIActivity.h"
#import "PocketAPI.h"
#import "BWVideo.h"
#import "SVProgressHUD.h"

@interface PocketAPIActivity ()

@property (strong, nonatomic) NSArray *videos;

@end

@implementation PocketAPIActivity

- (NSString *)activityType
{
	return @"Pocket";
}

- (NSString *)activityTitle
{
	return NSLocalizedString(@"Save to Pocket", nil);
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"PocketActivity"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (![PocketAPI sharedAPI].loggedIn) return NO;

    for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:BWVideo.class]) {
			NSURL *pocketURL = [NSURL URLWithString:[[PocketAPI pocketAppURLScheme] stringByAppendingString:@":test"]];
			if ([[UIApplication sharedApplication] canOpenURL:pocketURL] || [PocketAPI sharedAPI].loggedIn) {
				return YES;
			}
		}
	}
	
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	NSMutableArray *videos = [NSMutableArray array];
	
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:BWVideo.class]) {
			[videos addObject:activityItem];
		}
	}

	self.videos = [videos copy];
}

- (void)performActivity {
	__block NSUInteger videosLeft = self.videos.count;
	__block BOOL videoFailed = NO;

	for (BWVideo *video in self.videos) {
        [[PocketAPI sharedAPI] saveURL:video.videoHighURL
                             withTitle:video.name
                               handler: ^(PocketAPI *api, NSURL *url, NSError *error)
        {
			if (error != nil) videoFailed = YES;
			videosLeft--;
			if (videosLeft == 0) [self activityDidFinish:!videoFailed];
		}];
	}
}

- (void)activityDidFinish:(BOOL)completed {
    if (completed) {
        [SVProgressHUD showSuccessWithStatus:@"Saved to Pocket"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Failed to save to Pocket"];
    }
    [super activityDidFinish:completed];
}


+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

@end