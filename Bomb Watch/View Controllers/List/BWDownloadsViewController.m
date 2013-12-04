//
//  BWDownloadsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownloadsViewController.h"
#import "BWDownloadDataStore.h"
#import "BWVideoDetailViewController.h"

NSString *const kBWDownloadDetailSegue = @"kBWDownloadDetailSegue";

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.downloads = [[[BWDownloadDataStore defaultStore] allDownloads] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloads.count;
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

    BWDownload *download = self.downloads[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %d", download.video.name, download.quality];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kBWDownloadDetailSegue sender:self.downloads[indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kBWDownloadDetailSegue]) {
        BWVideoDetailViewController *detail = (BWVideoDetailViewController *)segue.destinationViewController;
        
        detail.video = ((BWDownload *)sender).video;
        // TODO set preselected quality
    }
}

@end
