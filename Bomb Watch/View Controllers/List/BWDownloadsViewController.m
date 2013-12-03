//
//  BWDownloadsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownloadsViewController.h"
#import "BWDownloadDataStore.h"

@interface BWDownloadsViewController ()
@property (strong, nonatomic) NSMutableArray *downloads;
@end

@implementation BWDownloadsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.downloads = [[[BWDownloadDataStore defaultStore] allDownloads] mutableCopy];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.downloads.count;
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"kBWDownloadCellIdentifier";
    
    PDGesturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:self.tableView
                                                                   style:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
    }

    cell.textLabel.text = @"testing";
    
    return cell;
}

@end
