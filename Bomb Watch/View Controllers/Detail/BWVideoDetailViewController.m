//
//  BWVideoDetailViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PocketAPIActivity.h"
#import "PocketAPI.h"
#import "SVProgressHUD.h"
#import "GiantBombAPIClient.h"
#import "EVCircularProgressView.h"
#import "BWOpenOnGBActivity.h"
#import "BWVideoPlayerViewController.h"
#import "BWVideo.h"
#import "NSString+Extensions.h"
#import "BWVideoDownloader.h"
#import "BWDownloadDataStore.h"
#import "BWColors.h"
#import "UIImage+ImageEffects.h"
#import "BWNameFormatter.h"
#import "BWSettings.h"
#import "BWTwitter.h"

#define kSummarySection    0
#define kVideoDetailCell   0

#define kOptionsSection    1
#define kQualityCell       0
#define kQualityPickerCell 1
#define kVideoBylineCell   2
#define kVideoDurationCell 3

#define kBWToolbarDownloadItemPosition 2

#define kBWImageCoverTintColor [UIColor colorWithWhite:0.0 alpha:0.30]
#define kBWImageCoverBlurRadius 2.0f
#define kBWImageCoverSaturation 0.9f

#define kBWMinimumBlurRadiusDelta 0.1f

@interface BWVideoDetailViewController ()
@property (strong, nonatomic) BWVideoPlayerViewController *player;
@property BOOL pickerVisible;
@property (strong, nonatomic) BWDownload *download;
@property (strong, nonatomic) EVCircularProgressView *progressView;
@property float cachedBlurRadius;
@property (strong, nonatomic) UIImage *previewImage;
@end

@implementation BWVideoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kBWGiantBombCharcoalColor;
    self.tableView.separatorColor  = [UIColor grayColor];
    self.qualityLabel.textColor = [UIColor lightGrayColor];
    self.bylineCell.detailTextLabel.textColor = [UIColor lightGrayColor];
    self.durationCell.detailTextLabel.textColor = [UIColor lightGrayColor];

    self.labelTitle.text = self.video.name;
    self.labelDescription.text = self.video.summary;
    self.bylineCell.textLabel.text = [BWNameFormatter realNameForUser:self.video.user];
    self.bylineCell.detailTextLabel.text = [BWNameFormatter twitterHandleForUser:self.video.user];

    [self selectQuality:self.quality];

    [self.preview setImageWithURLRequest:[NSURLRequest requestWithURL:self.video.imageSmallURL]
                        placeholderImage:nil
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         self.previewImage = image;
         [self updateImageBlurWithRadius:kBWImageCoverBlurRadius];
     }
                                   failure:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[BWDownloadDataStore defaultStore] downloadExistsForVideo:self.video quality:self.quality]) {
        self.download = [[BWDownloadDataStore defaultStore] downloadForVideo:self.video quality:self.quality];
    } else {
        self.download = nil;
    }

    [self refreshViews];
}

- (void)selectQuality:(int)quality
{
    [self.qualityPicker selectRow:quality inComponent:0 animated:NO];
    [self pickerView:self.qualityPicker didSelectRow:quality inComponent:0];
}

- (void)updateDurationLabel
{
    NSTimeInterval played = [BWSettings progressForVideo:self.video];
    NSTimeInterval duration = self.video.length;
    
    if (played > 0) {
        self.durationCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString stringFromDuration:played], [NSString stringFromDuration:duration]];
    } else {
        self.durationCell.detailTextLabel.text = [NSString stringFromDuration:duration];
    }
}

#pragma mark - UITableViewDelegate protocol methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kOptionsSection && indexPath.row == kQualityCell) {
        self.pickerVisible = !self.pickerVisible;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } else if (indexPath.section == kOptionsSection && indexPath.row == kVideoBylineCell) {
        [BWTwitter openTwitterUser:self.bylineCell.detailTextLabel.text];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kOptionsSection) {
        if (indexPath.row == kQualityCell) {
            return 44;
        } else if (indexPath.row == kQualityPickerCell) {
            if (self.pickerVisible) return 90;
            else return 0;
        } else if (indexPath.row == kVideoBylineCell || indexPath.row == kVideoDurationCell) {
            return 44;
        }
    } else if (indexPath.section == kSummarySection) {
        return [self.labelDescription sizeThatFits:self.labelDescription.frame.size].height + 20;
    }

    return 44;
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

#pragma mark - UIScrollViewDelegate protocol methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = scrollView.contentOffset.y;
    if (y < 0) {
        self.preview.frame = CGRectMake(0, y, 320 + -y, 180 + -y);
        self.preview.center = CGPointMake(self.view.center.x, self.preview.center.y);

        float blurRadius = kBWImageCoverBlurRadius + y / (scrollView.frame.size.height / 10);
        
        // only apply blur after the minimum delta - for performance
        if(fabsf(self.cachedBlurRadius - blurRadius) > kBWMinimumBlurRadiusDelta) {
            [self updateImageBlurWithRadius:blurRadius];
        }
    }
    
    self.labelTitle.alpha = 1 + y / (scrollView.frame.size.height / 10);
}

- (void)updateImageBlurWithRadius:(float)radius
{
    UIImage *blurredImage = [self.previewImage applyBlurWithRadius:radius
                                                         tintColor:kBWImageCoverTintColor
                                             saturationDeltaFactor:kBWImageCoverSaturation
                                                         maskImage:nil];
    
    [self.preview setImage:blurredImage];
    self.cachedBlurRadius = radius;
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];

    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:qualities[row]
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([[BWDownloadDataStore defaultStore] downloadExistsForVideo:self.video quality:row]) {
        self.download = [[BWDownloadDataStore defaultStore] downloadForVideo:self.video quality:row];
    } else {
        self.download = nil;
    }
    [self refreshViews];
}

#pragma mark - UIPickerViewDataSource protocol methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.video.videoHDURL) return 4;

    return 3;
}

#pragma mark - Video player control

- (IBAction)playButtonPressed:(id)sender
{
    if ([self canStreamVideo]) {
        self.player = [[BWVideoPlayerViewController alloc] initWithVideo:self.video quality:[self selectedQuality]];
        self.player.delegate = self;
        [self presentMoviePlayerViewControllerAnimated:self.player];
        [self.player play];
    } else if ([AFNetworkReachabilityManager sharedManager].reachable && ![self canStreamVideo]) {
        [SVProgressHUD showErrorWithStatus:@"Can't stream this video over cellular"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Network unreachable"];
    }
}

#pragma mark - BWVideoPlayerDelegate protocol methods

- (void)videoDidFinishPlaying
{
    self.player = nil;
    [self dismissMoviePlayerViewControllerAnimated];
    [self updateWatchedButton];
    [self updateDurationLabel];
}

#pragma mark - Action sheet

- (IBAction)actionButtonPressed:(id)sender
{
    PocketAPIActivity *pocket = [[PocketAPIActivity alloc] init];
    BWOpenOnGBActivity *gb = [[BWOpenOnGBActivity alloc] init];

    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:@[self.video, self.video.siteDetailURL]
                                                    applicationActivities:@[gb, pocket]];

    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Favorites

- (IBAction)favoriteButtonPressed:(id)sender
{
    [self.video setFavorited:![self.video isFavorited]];
    [self updateFavoriteButton];

    // TODO: show image with status
    if ([self.video isFavorited]) {
        [SVProgressHUD showSuccessWithStatus:@"Favorited"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Unfavorited"];
    }
}

- (void)updateFavoriteButton
{
    if ([self.video isFavorited]) {
        [self.favoritedButton setImage:[UIImage imageNamed:@"toolbar-fav-full"]];
    } else {
        [self.favoritedButton setImage:[UIImage imageNamed:@"toolbar-fav-outline"]];
    }
}

#pragma mark - Downloads

- (IBAction)downloadButtonPressed:(id)sender
{
    AFNetworkReachabilityManager *reach = [AFNetworkReachabilityManager sharedManager];

    if (reach.reachableViaWiFi) {
        if (!self.download) {
            [SVProgressHUD showSuccessWithStatus:@"Downloading"];
            BWDownload *download = [[BWVideoDownloader defaultDownloader] downloadVideo:self.video quality:[self selectedQuality]];
            self.download = download;
        } else if ([self.download isInProgress]) {
            [SVProgressHUD showSuccessWithStatus:@"Download paused"];
            [[BWVideoDownloader defaultDownloader] pauseDownload:self.download];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"Download resumed"];
            [[BWVideoDownloader defaultDownloader] resumeDownload:self.download];
        }
    } else if (reach.reachableViaWWAN) {
        [SVProgressHUD showErrorWithStatus:@"Can't download over cellular"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Network unreachable"];
    }

    [self updateDownloadButton];
}

- (void)updateDownloadButton
{
    NSMutableArray *items = [self.toolbar.items mutableCopy];

    if (self.download && ![self.download isComplete]) {
        self.progressView = [[EVCircularProgressView alloc] init];
        self.progressView.userInteractionEnabled = YES;
        self.progressView.enabled = YES;
        self.downloadButton = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
        [self.progressView addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self performSelector:@selector(updateProgressView) withObject:nil afterDelay:0.2f];
    } else {
        self.progressView = nil;
        self.downloadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarDownload"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(downloadButtonPressed:)];
        if (self.download && [self.download isComplete]) {
//            self.downloadButton.userInteractionEnabled = NO;
            self.downloadButton.image = [UIImage imageNamed:@"ToolbarDownloadFull"];
        }
    }

    items[kBWToolbarDownloadItemPosition] = self.downloadButton;
    self.toolbar.items = items;
}

- (void)updateProgressView
{
    if (self.progressView) {
        [self.progressView setProgress:self.download.progress animated:NO];

        if ([self.download isComplete]) {
            [self updateDownloadButton];
        } else if ([self.download isInProgress]) {
            [self performSelector:@selector(updateProgressView) withObject:nil afterDelay:0.2f];
        }
    }
}

#pragma mark - Watched status

- (IBAction)watchedButtonPressed:(id)sender
{
    // TODO: show image with status
    [self.video setWatched:![self.video isWatched]];

    if ([self.video isWatched]) {
        [SVProgressHUD showSuccessWithStatus:@"Watched"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Unwatched"];
    }

    [self updateWatchedButton];
}

- (void)updateWatchedButton
{
    if ([self.video isWatched]) {
        self.watchedButton.image = [UIImage imageNamed:@"ToolbarCheckFull"];
    } else {
        self.watchedButton.image = [UIImage imageNamed:@"ToolbarCheck"];
    }
}

#pragma mark - Utility

- (void)refreshViews
{
    [self updateDownloadButton];
    [self updateWatchedButton];
    [self updateFavoriteButton];
    [self updateDurationLabel];

    [self.qualityPicker reloadAllComponents];
    self.qualityLabel.text = [[self pickerView:self.qualityPicker attributedTitleForRow:[self selectedQuality] forComponent:0] string];

    [self.tableView reloadData];
}

- (BWVideoQuality)selectedQuality
{
    return [self.qualityPicker selectedRowInComponent:0];
}

- (BOOL)canStreamVideo
{
    AFNetworkReachabilityManager *reach = [AFNetworkReachabilityManager sharedManager];
    return reach.reachableViaWiFi || (reach.reachableViaWWAN && [self.video canStreamOverCellular]);
}

@end
