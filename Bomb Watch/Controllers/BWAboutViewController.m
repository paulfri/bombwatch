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

@implementation BWAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTwitterSection && indexPath.row == kTwitterCell) {
        // TODO: tweetbot > twitterapp > twitterweb
        NSURL *twitterURL = [NSURL URLWithString:@"https://twitter.com/bombwatch"];
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else if (indexPath.section == kMailSection && indexPath.row == kMailCell) {
        NSURL *mailURL = [NSURL URLWithString:@"mailto:cosmonautics@laika.io"];
        [[UIApplication sharedApplication] openURL:mailURL];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
