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
#import "EVCircularProgressView.h"
#import "BWVideoTableViewCell.h"
#import "BWColors.h"

NSString *const kBWDownloadDetailSegue = @"kBWDownloadDetailSegue";

@interface BWDownloadsViewController ()
@property (strong, nonatomic) NSMutableArray *downloads;
@end

@implementation BWDownloadsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.enabled = YES;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    
    BWVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[BWVideoTableViewCell alloc] initForGesturedTableView:self.tableView
                                                                style:UITableViewCellStyleSubtitle
                                                      reuseIdentifier:identifier];

        __unsafe_unretained typeof(self) _self = self;
        void (^deleteDownload)(PDGesturedTableView*, PDGesturedTableViewCell*) = ^(PDGesturedTableView *tableView, PDGesturedTableViewCell *cell)
        {
            BWVideoTableViewCell *downloadCell = (BWVideoTableViewCell *)cell;
            BWDownload *download = [_self downloadAtIndexPath:[tableView indexPathForCell:downloadCell]];

            [tableView removeCell:cell completion:^{
                [[BWDownloadDataStore defaultStore] deleteDownload:download];
                [self.downloads removeObject:download];
            }];
        };

        PDGesturedTableViewCellSlidingFraction *deleteFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                  color:kBWGiantBombCharcoalColor
                                                     activationFraction:-0.15];

        [deleteFraction setDidReleaseBlock:deleteDownload];
        [cell addSlidingFraction:deleteFraction];

        cell.bouncesAtLastSlidingFraction = NO;
    }

    BWDownload *download = self.downloads[indexPath.row];

    [cell setBackgroundImageWithURL:download.video.imageSmallURL];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", download.video.name];

    if (![download isComplete]) {
        cell.accessoryView = [[EVCircularProgressView alloc] init];
        [self updateProgressViewAndDownload:@[cell.accessoryView, download]];
    } else {
        cell.accessoryView = nil;
    }

    return cell;
}

- (void)updateProgressViewAndDownload:(NSArray *)progressViewAndDownload
{
    EVCircularProgressView *progressView = (EVCircularProgressView *)[progressViewAndDownload firstObject];
    BWDownload *download = (BWDownload *)[progressViewAndDownload lastObject];

    if ([download isComplete]) {
        [progressView removeFromSuperview];
    } else {
        [progressView setProgress:download.progress animated:NO];
        [self performSelector:@selector(updateProgressViewAndDownload:) withObject:progressViewAndDownload afterDelay:0.5f];
    }
}

- (BWDownload *)downloadAtIndexPath:(NSIndexPath *)indexPath
{
    return self.downloads[indexPath.row];
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
        BWDownload *download = (BWDownload *)sender;

        detail.video = download.video;
        detail.quality = download.quality;
    }
}

@end
