//
//  BWDownloadsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWDownloadsViewController.h"
#import "BWDownloadsDataStore.h"
#import "BWDownload.h"
#import "EVCircularProgressView.h"
#import "GiantBombAPIClient.h"
#import "SVProgressHUD.h"
#import "AFDownloadRequestOperation.h"

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
                                             selector:@selector(updateProgress:)
                                                 name:@"VideoProgressUpdateNotification"
                                               object:nil];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VideoProgressUpdateNotification"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// this works!!
- (void)updateProgress:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    NSNumber *progress = dict[@"progress"];
    NSIndexPath *path = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] indexPathForObject:download];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    EVCircularProgressView *progressView = (EVCircularProgressView *)[cell viewWithTag:990];
    [progressView setProgress:[progress floatValue] animated:YES];
//    NSLog(@"%@", dict);
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

    cell.textLabel.text = download.name;
    EVCircularProgressView *progressView = (EVCircularProgressView *)[cell viewWithTag:990];
    
    if ([download downloadComplete]) {
        progressView.hidden = YES;
    }

    [progressView addTarget:self action:@selector(progressViewPressed:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)progressViewPressed:(id)sender {
    EVCircularProgressView *view = (EVCircularProgressView *)sender;
    UITableViewCell *cell = (UITableViewCell *)view.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BWDownload *download = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] objectAtIndexPath:indexPath];
    [SVProgressHUD showSuccessWithStatus:@"Download paused"];

    NSLog(@"%@", download.path);
    for (NSOperation *op in [[[GiantBombAPIClient defaultClient] operationQueue] operations]) {
        if ([op isKindOfClass:[AFDownloadRequestOperation class]]) {
            AFDownloadRequestOperation *dl = (AFDownloadRequestOperation *)op;
            NSLog(@"%@ and %@", [dl.request.URL absoluteString], download.path);
            if ([[dl.request.URL absoluteString] isEqualToString:download.path])
                [op cancel];
        }
    }
//    [[[GiantBombAPIClient defaultClient] operationQueue] operations];
//    [[GiantBombAPIClient defaultClient] cancelAllHTTPOperationsWithMethod:nil path:download.path];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[BWDownloadsDataStore defaultStore] deleteDownloadWithIndexPath:indexPath];
    }
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
