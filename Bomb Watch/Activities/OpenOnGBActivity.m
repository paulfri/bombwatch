//
//  OpenOnGBActivity.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "OpenOnGBActivity.h"
#import "GBVideo.h"
#import "SVProgressHUD.h"

@interface OpenOnGBActivity ()

@property (strong, nonatomic) NSArray *videoURLs;

@end

@implementation OpenOnGBActivity

- (NSString *)activityType {
	return @"OpenOnGB";
}

- (NSString *)activityTitle {
	return NSLocalizedString(@"View on Giant Bomb", nil);
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"BombTableHeader"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) return YES;
	}
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	NSMutableArray *urls = [NSMutableArray array];
	
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			[urls addObject:activityItem];
		}
	}

	self.videoURLs = [urls copy];
}

- (void)performActivity {
//	__block NSUInteger urlsLeft = self.videoURLs.count;
//	__block BOOL videoFailed = NO;

	for (NSURL *url in self.videoURLs) {
        // do something
	}
}

- (void)activityDidFinish:(BOOL)completed {
    if (!completed)
        [SVProgressHUD showErrorWithStatus:@"Error"];
    [super activityDidFinish:completed];
}

@end