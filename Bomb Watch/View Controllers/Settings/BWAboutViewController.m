//
//  BWAboutViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWAboutViewController.h"
#import "BWTwitter.h"

#define kBWContactSection     0
#define kBWContactTwitterCell 0
#define kBWContactMailCell    1

#define kBWAttributionSection 3
#define kBWAttributionCell    0

#define kBWAttributionCellPadding 10
#define kBWCopyrightCellHeight 80
#define kBWContactCellHeight   44

#define kBWAttributionHeightBound 2670

NSString *const kBWTwitterHandle = @"paulfri";
NSString *const kBWMailAddress   = @"paulrfri@gmail.com";

@implementation BWAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.aboutLabel.text attributes:dict];
    NSArray *titles = @[@"AFNetworking", @"SVProgressHUD", @"PDGesturedTableView", @"Mantle"];

    for (NSString *title in titles) {
        [string addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:17.0]
                       range:[self.aboutLabel.text rangeOfString:title]];
    }

    self.aboutLabel.frame = [string boundingRectWithSize:CGSizeMake(self.aboutLabel.frame.size.width, kBWAttributionHeightBound)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];

    self.aboutLabel.attributedText = string;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kBWContactSection && indexPath.row == kBWContactTwitterCell) {
        [BWTwitter openTwitterUser:kBWTwitterHandle];
    } else if (indexPath.section == kBWContactSection && indexPath.row == kBWContactMailCell) {
        NSURL *mailURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", kBWMailAddress]];
        [[UIApplication sharedApplication] openURL:mailURL];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kBWAttributionSection && indexPath.row == kBWAttributionCell) {
        return self.aboutLabel.frame.size.height + (kBWAttributionCellPadding * 2);
    } else if (indexPath.section == kBWContactSection) {
        return kBWContactCellHeight;
    }

    return kBWCopyrightCellHeight;
}

@end
