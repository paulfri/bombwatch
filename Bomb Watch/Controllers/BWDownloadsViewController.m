//
//  BWDownloadsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownloadsViewController.h"
#import "BWVideoDetailViewController.h"
#import "BWDownloadsDataStore.h"
#import "BWDownload.h"
#import "EVCircularProgressView.h"
#import "GiantBombAPIClient.h"
#import "SVProgressHUD.h"
#import "AFDownloadRequestOperation.h"
#import "GBVideo.h"

@interface BWDownloadsViewController ()

@end

@implementation BWDownloadsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[BWDownloadsDataStore defaultStore] setTableView:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markDownloadProgress:)
                                                 name:@"VideoProgressUpdateNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markDownloadComplete:)
                                                 name:@"VideoDownloadCompleteNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markDownloadError:)
                                                 name:@"VideoDownloadErrorNotification"
                                               object:nil];

    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VideoProgressUpdateNotification"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VideoDownloadCompleteNotification"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VideoDownloadErrorNotification"
                                                  object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)markDownloadProgress:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    NSNumber *progress = dict[@"progress"];
    NSIndexPath *path = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] indexPathForObject:download];
    EVCircularProgressView *progressView = (EVCircularProgressView *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
    [progressView setProgress:[progress floatValue] animated:YES];
}

- (void)markDownloadComplete:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    NSIndexPath *path = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] indexPathForObject:download];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)markDownloadError:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    NSIndexPath *path = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] indexPathForObject:download];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    EVCircularProgressView *progressView = (EVCircularProgressView *)[cell accessoryView];
    [progressView setProgress:0];
}

#pragma mark - UITableViewDataSource protocol methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[[BWDownloadsDataStore defaultStore] fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DownloadCell" forIndexPath:indexPath];
    BWDownload *download = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] objectAtIndexPath:indexPath];

    cell.textLabel.text = ((GBVideo *)download.video).name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", download.quality];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // this will get ignored if set to progress view later

    EVCircularProgressView *progressView = [[EVCircularProgressView alloc] init];
    if (download.complete) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = nil;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        progressView.userInteractionEnabled = YES;
        progressView.frame = CGRectMake(0, 0, 28.0, 28.0);
        [progressView addTarget:self action:@selector(progressViewPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (download.paused)
            [progressView setProgress:[download.progress floatValue] animated:NO];
        cell.accessoryView = progressView;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[BWDownloadsDataStore defaultStore] deleteDownloadWithIndexPath:indexPath];
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BWDownload *dl = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if ([identifier isEqualToString:@"showVideoDetailSegue"] && dl.complete) {
        return YES;
    }
    return NO;
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showVideoDetailSegue"]) {
        BWVideoDetailViewController *destination = [segue destinationViewController];
        BWDownload *dl = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        destination.video = (GBVideo *)dl.video;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - pausing/resuming downloads

- (void)progressViewPressed:(id)sender {
    EVCircularProgressView *view = (EVCircularProgressView *)sender;
    UITableViewCell *cell = (UITableViewCell *)view.superview.superview;
    BWDownload *download = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForCell:cell]];

    if (download.paused) {
        // TODO: replace success with play image
        [SVProgressHUD showSuccessWithStatus:@"Download resumed"];
        [[BWDownloadsDataStore defaultStore] resumeDownload:download];
    } else {
        // TODO: replace success with pause image
        [SVProgressHUD showSuccessWithStatus:@"Download paused"];
        [[BWDownloadsDataStore defaultStore] cancelRequestForDownload:download withProgressView:view];
    }

    [self.tableView reloadData];
}


@end
