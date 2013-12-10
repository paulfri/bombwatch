//
//  BWTableViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWTableViewController.h"
#import "BWColors.h"

@implementation BWTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = kBWGiantBombCharcoalColor;
    self.tableView.separatorColor  = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addTableHeader];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        ((UITableViewHeaderFooterView *)view).textLabel.textColor = [UIColor lightGrayColor];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        ((UITableViewHeaderFooterView *)view).textLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)addTableHeader
{
    UIImage *bomb = [UIImage imageNamed:@"BombTableHeader"];
    CGSize bombSize = CGSizeMake(bomb.size.width * 0.7, bomb.size.height * 0.7);

    CGRect rect = self.view.bounds;
    UIImageView *bombImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width / 2 - (bombSize.width / 2), 0, bombSize.width, bombSize.height)];
    [bombImageView setImage:bomb];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bombImageView.bounds.size.width, bombImageView.bounds.size.height)];
    [headerView addSubview:bombImageView];

    self.tableView.tableHeaderView = headerView;
    [self.tableView setContentInset:UIEdgeInsetsMake(-bombImageView.bounds.size.height, 0.0f, 0.0f, 0.0f)];
}

@end
