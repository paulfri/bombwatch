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

static NSString *cellIdentifier = @"kBWVideoListCellIdentifier";

#define kBWLeftSwipeFraction 0.15
#define kBWRightSwipeFraction 0.15

#define kBWLeftSwipeColor  [UIColor colorWithRed:0 green:178.0/255 blue:51.0/255 alpha:1]

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
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cache", self.category]];
        
        NSMutableArray *cachedVideos = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
        if (!cachedVideos) {
            [SVProgressHUD show];
            [self loadVideosForPage:self.page];
        } else {
            self.videos = cachedVideos;
        }
    }

    return self;
}

- (BWVideo *)videoAtIndexPath:(NSIndexPath *)indexPath
{
    return self.videos[indexPath.row];
}

- (void)refreshControlActivated
{
    self.page = 1;
    [self loadVideosForPage:self.page];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
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
        
        PDGesturedTableViewCellSlidingFraction *watchedFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                      color:kBWLeftSwipeColor
                                                         activationFraction:kBWLeftSwipeFraction];
        
        [watchedFraction setDidReleaseBlock:toggleWatched];
        [cell addSlidingFraction:watchedFraction];
        
        PDGesturedTableViewCellSlidingFraction *favoriteFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"star-gold-outline"]
                                                                      color:[UIColor blackColor]
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

- (void)loadVideosForPage:(NSInteger)page
{
    [[BWVideoFetcher defaultFetcher] fetchVideosForCategory:self.category
                                                       page:page
                                                    success:^(NSArray *results)
    {
        if (page == 1) {
            self.videos = [results copy];
            
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cache", self.category]];

            [NSKeyedArchiver archiveRootObject:self.videos
                                        toFile:filePath];
        } else {
            self.videos = [[self.videos arrayByAddingObjectsFromArray:results] mutableCopy];
        }
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
    }
                                                    failure:nil];
}

#pragma mark - table view delegate

- (void)tableView:(PDGesturedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWVideo *video = [self videoAtIndexPath:indexPath];
    
    if (video && self.delegate && [self.delegate respondsToSelector:@selector(videoSelected:)]) {
        [self.delegate videoSelected:video];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffsetY = scrollView.contentOffset.y + [[UIScreen mainScreen] bounds].size.height;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    if (currentOffsetY > ((contentHeight * 3)/ 4.0)) {
        // if it's >=, we're all caught up and can load the next page
        // if it's < , then there should already be a load in progress
        if(self.videos.count >= (self.page * kBWVideosPerPage)) {
            self.page++;
            [self loadVideosForPage:self.page];
        }
    }
}

@end
