//
//  BWTableViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWTableViewController.h"

@implementation BWTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // bomb table header
    CGRect screenRect = [UIScreen mainScreen].bounds;
    UIImageView *bombImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenRect.size.width / 2 - 10, 0, 20, 40)];
    [bombImageView setImage:[UIImage imageNamed:@"BombTableHeader"]];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bombImageView.bounds.size.width, bombImageView.bounds.size.height)];
    [headerView addSubview:bombImageView];
    [headerView sendSubviewToBack:bombImageView];
    self.tableView.tableHeaderView = headerView;
    [self.tableView setContentInset:UIEdgeInsetsMake(-bombImageView.bounds.size.height, 0.0f, 0.0f, 0.0f)];
}

@end
