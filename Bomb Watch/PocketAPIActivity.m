//
//  PocketAPIActivity.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "PocketAPIActivity.h"
#import "PocketAPI.h"

@implementation PocketAPIActivity {
	NSArray *_URLs;
}

- (NSString *)activityType {
	return @"Pocket";
}

- (NSString *)activityTitle {
	return NSLocalizedString(@"Save to Pocket", nil);
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"PocketActivity"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			NSURL *pocketURL = [NSURL URLWithString:[[PocketAPI pocketAppURLScheme] stringByAppendingString:@":test"]];
			
			if ([[UIApplication sharedApplication] canOpenURL:pocketURL] || [PocketAPI sharedAPI].loggedIn) {
				return YES;
			}
		}
	}
	
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	NSMutableArray *URLs = [NSMutableArray array];
	
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			[URLs addObject:activityItem];
		}
	}

	_URLs = [URLs copy];
}

- (void)performActivity {
	__block NSUInteger URLsLeft = _URLs.count;
	__block BOOL urlFailed = NO;

	for (NSURL *url in _URLs) {
		[[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *api, NSURL *url, NSError *error) {
			if (error != nil)
				urlFailed = YES;

			URLsLeft--;

			if (URLsLeft == 0)
				[self activityDidFinish:!urlFailed];
		}];
	}
}

@end