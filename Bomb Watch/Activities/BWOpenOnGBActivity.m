//
//  BWOpenOnGBActivity.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWOpenOnGBActivity.h"

@interface BWOpenOnGBActivity ()

@property (strong, nonatomic) NSURL *URL;

@end

@implementation BWOpenOnGBActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
	return @"OpenOnGB";
}

- (NSString *)activityTitle
{
	return NSLocalizedString(@"View on Giant Bomb", nil);
}

- (UIImage *)activityImage
{
	return [UIImage imageNamed:@"BombTableHeader"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:NSURL.class]) {
            return YES;
        }
	}
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:NSURL.class]) {
			self.URL = activityItem;
            return;
		}
	}
}

- (void)performActivity
{
    if (self.URL != nil && [self.URL isKindOfClass:NSURL.class]) {
        [[UIApplication sharedApplication] openURL:self.URL];
        [self activityDidFinish:YES];
    }

    [self activityDidFinish:NO];
}

@end