//
//  BWListController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWListController.h"
#import "BWVideo.h"
#import "BWVideoFetcher.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"
#import "SVProgressHUD.h"
#import "BWFavoriteView.h"
#import "BWVideoTableViewCell.h"
#import "BWVideoDataStore.h"
#import "BWColors.h"

static NSString *cellIdentifier = @"kBWVideoListCellIdentifier";

#define kBWLeftSwipeFraction 0.15
#define kBWFarLeftSwipeFraction 0.4
#define kBWRightSwipeFraction 0.15

#define kBWInfiniteScrollCellThreshold 5 // the number of cells from the bottom

@interface BWListController ()

@property (strong, nonatomic) NSString *searchText;

@end

@implementation BWListController

- (id)initWithTableView:(PDGesturedTableView *)tableView category:(NSString *)category
{
    self = [super init];

    if (self) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.enabled = YES;
        
        self.page = 1;
        self.category = category;
        self.videos = [[NSMutableArray alloc] init];
        
        UITableViewController *tableViewController = [[UITableViewController alloc] init];
        tableViewController.tableView = self.tableView;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(refreshControlActivated)
                      forControlEvents:UIControlEventValueChanged];
        tableViewController.refreshControl = self.refreshControl;
        
        self.videos = [[[BWVideoDataStore defaultStore] cachedVideosForCategory:self.category] mutableCopy];
        
        if (self.videos.count == 0) {
            [SVProgressHUD show];
            [self loadVideosForPage:self.page searchText:nil];
        }
    }

    return self;
}

- (void)search:(NSString *)text
{
    self.searchText = text;
    [self loadVideosForPage:1 searchText:self.searchText];
}

- (BWVideo *)videoAtIndexPath:(NSIndexPath *)indexPath
{
    return self.videos[indexPath.row];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWVideoTableViewCell *cell = (BWVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[BWVideoTableViewCell alloc] init];
        __unsafe_unretained typeof(self) _self = self;
        
        void (^toggleWatched)(PDGesturedTableView*, PDGesturedTableViewCell*) = ^(PDGesturedTableView *tableView, PDGesturedTableViewCell *cell)
        {
            BWVideoTableViewCell *videoCell = (BWVideoTableViewCell *)cell;
            BWVideo *video = [_self videoAtIndexPath:[tableView indexPathForCell:videoCell]];
            [video setWatched:![video isWatched]];
            [videoCell setWatched:[video isWatched] animated:YES];
            [tableView updateAnimatedly:YES];
        };
        
        void (^toggleFavorite)(PDGesturedTableView*, PDGesturedTableViewCell*) = ^(PDGesturedTableView *tableView, PDGesturedTableViewCell *cell)
        {
            BWVideoTableViewCell *videoCell = (BWVideoTableViewCell *)cell;
            BWVideo *video = [_self videoAtIndexPath:[tableView indexPathForCell:videoCell]];
            [video setFavorited:![video isFavorited]];
            [videoCell setFavorited:[video isFavorited] animated:YES];
            [tableView updateAnimatedly:YES];
        };
        
        cell = [[BWVideoTableViewCell alloc] initForGesturedTableView:self.tableView
                                                                style:UITableViewCellStyleDefault
                                                      reuseIdentifier:cellIdentifier];
        
        PDGesturedTableViewCellSlidingFraction *watchNowFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"ToolbarPlay"]
                                                                      color:kBWGiantBombCharcoalColor
                                                         activationFraction:kBWFarLeftSwipeFraction];
        
        [watchNowFraction setDidReleaseBlock:toggleWatched];
        [cell addSlidingFraction:watchNowFraction];
        
        PDGesturedTableViewCellSlidingFraction *setWatchedFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"ToolbarCheck"]
                                                                      color:kBWGiantBombCharcoalColor
                                                         activationFraction:kBWLeftSwipeFraction];
        
        [setWatchedFraction setDidReleaseBlock:toggleWatched];
        [cell addSlidingFraction:setWatchedFraction];
        
        PDGesturedTableViewCellSlidingFraction *favoriteFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"star-gold-outline"]
                                                                      color:kBWGiantBombCharcoalColor
                                                         activationFraction:-kBWRightSwipeFraction];
        
        [favoriteFraction setDidReleaseBlock:toggleFavorite];
        [cell addSlidingFraction:favoriteFraction];
    }
    
    BWVideo *video = [self videoAtIndexPath:indexPath];
    cell.textLabel.text = video.name;

    [cell setFavorited:[video isFavorited] animated:NO];
    [cell   setWatched:[video isWatched]   animated:NO];
    [cell setBackgroundImageWithURL:video.imageSmallURL];
    
    return cell;
}

- (void)loadVideosForPage:(NSInteger)page searchText:(NSString *)searchText
{
    [[BWVideoFetcher defaultFetcher] fetchVideosForCategory:self.category
                                               searchString:searchText
                                                       page:page
                                                    success:^(NSArray *results)
     {
         if (page == 1) {
             self.videos = [results mutableCopy];
            [SVProgressHUD dismiss];
         } else {
             [self.videos addObjectsFromArray:results];

             [UIView transitionWithView:self.tableView
                               duration:0.35f
                                options:UIViewAnimationOptionTransitionCrossDissolve
                             animations:^(void) { [self.tableView reloadData]; }
                             completion:nil];
         }

         [self.refreshControl endRefreshing];
         self.tableView.tableFooterView = [[UIView alloc] init];

         if (page == 1 && !searchText && self.delegate && [self.delegate respondsToSelector:@selector(tableViewContentsReset)]) {
             [self.delegate tableViewContentsReset];
         } else if (page == 1 && self.delegate && [self.delegate respondsToSelector:@selector(searchDidCompleteWithSuccess)]) {
             [self.delegate searchDidCompleteWithSuccess];
         }
    }
                                                    failure:^(NSError *error)
    {
        if (searchText && self.delegate && [self.delegate respondsToSelector:@selector(searchDidCompleteWithFailure)]) {
            [self.delegate searchDidCompleteWithFailure];
        }
    }];
}

#pragma mark - table view delegate

- (void)tableView:(PDGesturedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWVideo *video = [self videoAtIndexPath:indexPath];
    
    if (video && self.delegate && [self.delegate respondsToSelector:@selector(videoSelected:)]) {
        [self.delegate videoSelected:video];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= ([tableView numberOfRowsInSection:0] - kBWInfiniteScrollCellThreshold) && self.videos.count >= (self.page * kBWVideosPerPage)) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        view.bounds = CGRectMake(view.bounds.origin.x, view.bounds.origin.x, view.bounds.size.width, tableView.rowHeight);
        [view startAnimating];
        self.tableView.tableFooterView = view;

        self.page++;
        [self loadVideosForPage:self.page searchText:self.searchText];
    }
}

#pragma mark - util

- (void)refreshControlActivated
{
    self.page = 1;
    [self loadVideosForPage:self.page searchText:nil];
    
    if ([self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

@end
