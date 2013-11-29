//
//  BWAboutViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWAboutViewController.h"

#define kTwitterSection 0
#define kTwitterCell    0

#define kMailSection    0
#define kMailCell       1

//static NSURL *mailURL = [NSURL URLWithString:@"https://twitter.com/bombwatch"];
static NSString *kBWTwitterHandle = @"bombwatch";

@implementation BWAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTwitterSection && indexPath.row == kTwitterCell) {

        // TODO make these static
        NSURL *tweetbotURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/timeline", kBWTwitterHandle]];
        NSURL *twitterifficURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitteriffic://account/%@/tweets", kBWTwitterHandle]];
        NSURL *twitterAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:@%@", kBWTwitterHandle]];
        NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", kBWTwitterHandle]];

        if ([[UIApplication sharedApplication] canOpenURL:tweetbotURL]) {
            [[UIApplication sharedApplication] openURL:tweetbotURL];
        } else if ([[UIApplication sharedApplication] canOpenURL:twitterifficURL]) {
            [[UIApplication sharedApplication] openURL:twitterifficURL];
        } else if ([[UIApplication sharedApplication] canOpenURL:twitterAppURL]) {
            [[UIApplication sharedApplication] openURL:twitterAppURL];
        } else
            [[UIApplication sharedApplication] openURL:twitterURL];

    } else if (indexPath.section == kMailSection && indexPath.row == kMailCell) {
        NSURL *mailURL = [NSURL URLWithString:@"mailto:cosmonautics@laika.io"];
        [[UIApplication sharedApplication] openURL:mailURL];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
