//
//  BWTwitter.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/8/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWTwitter.h"

@implementation BWTwitter

+ (void)openTwitterUser:(NSString *)user
{
    user = [user stringByReplacingOccurrencesOfString:@"@" withString:@""];

    //    NSURL *tweetbotURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/timeline", user]];
    NSURL *twitterifficURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitteriffic://account/%@/tweets", user]];
    NSURL *twitterAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:@%@", user]];
    NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", user]];

//    if ([[UIApplication sharedApplication] canOpenURL:tweetbotURL]) {
//        [[UIApplication sharedApplication] openURL:tweetbotURL];
//    } else if ([[UIApplication sharedApplication] canOpenURL:twitterifficURL]) {
    if ([[UIApplication sharedApplication] canOpenURL:twitterifficURL]) {
        [[UIApplication sharedApplication] openURL:twitterifficURL];
    } else if ([[UIApplication sharedApplication] canOpenURL:twitterAppURL]) {
        [[UIApplication sharedApplication] openURL:twitterAppURL];
    } else {
        [[UIApplication sharedApplication] openURL:twitterURL];
    }
}

@end
