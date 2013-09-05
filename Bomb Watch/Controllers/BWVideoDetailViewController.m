//
//  BWVideoDetailViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "GBVideo.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PocketAPIActivity.h"
#import "PocketAPI.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"
#import "GiantBombAPIClient.h"
//#import "EVCircularProgressView.h"
#import "BWDownloadsDataStore.h"
#import "BWDownload.h"
#import "OpenOnGBActivity.h"

// default quality when no downloads are present
#define kQualityCell        1
#define kQualityPickerCell  2
#define kVideoTitleCell     3
#define kVideoBylineCell    4
#define kVideoDetailCell    5

@interface BWVideoDetailViewController ()

@property (strong, nonatomic) MPMoviePlayerViewController *player;
@property (strong, nonatomic) NSArray *downloads;
@property BOOL pickerVisible;

@end

@implementation BWVideoDetailViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.video.name;
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self drawImagePulldown];

    self.titleLabel.text = self.video.name;
    self.descriptionLabel.text = self.video.summary;
    self.bylineLabel.text = [self bylineLabelText];
    self.durationLabel.text = [self durationLabelText];
}

    // Tweetbot-style image pulldown
- (void)drawImagePulldown {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 180)];
    
    __block UIImageView *imagePreview = self.imageView;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.video.imageMediumURL];
    [self.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        UIImage *playBtn = [UIImage imageNamed:@"video-play-lg"];
        
        UIGraphicsBeginImageContextWithOptions(image.size, FALSE, 0.0);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [playBtn drawInRect:CGRectMake(image.size.width/2 - (playBtn.size.width/2), image.size.height/2 - (playBtn.size.height/2), playBtn.size.width, playBtn.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        imagePreview.image = newImage;
    } failure:nil];

    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.cachedImageViewSize = self.imageView.frame;
    [self.tableView addSubview:self.imageView];
    [self.tableView sendSubviewToBack:self.imageView];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 180)];
    self.tableView.tableHeaderView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
    [self.tableView.tableHeaderView addGestureRecognizer:tapped];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.preselectedQuality)
        [self selectQuality:[self.preselectedQuality intValue]];
    else
        [self selectBestQuality];
    [self refreshViews];
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

- (void)refreshDownloadList {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"videoID == %@", self.video.videoID];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"quality" ascending:NO]];
    self.downloads = [[[BWDownloadsDataStore defaultStore] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
}

- (void)selectBestQuality {
    [self refreshDownloadList];
    if (self.downloads.count > 0) {
        int quality = [((BWDownload *)self.downloads[0]).quality intValue];
        [self selectQuality:quality];
    } else {
        [self selectQuality:[self defaultQuality]];
    }
}

- (void)selectQuality:(int)quality {
    [self.qualityPicker selectRow:quality inComponent:0 animated:NO];
    [self pickerView:self.qualityPicker didSelectRow:quality inComponent:0];
}

- (int)defaultQuality {
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
    int qual = [qualities indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuality"]];
    if (qual >= 0 && qual <= 3)
        return qual;
    return BWDownloadVideoQualityLow;
}

- (NSString *)durationLabelText {
    NSTimeInterval played = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] objectForKey:[NSString stringWithFormat:@"%@", self.video.videoID]] doubleValue];
    NSTimeInterval duration = [self.video.lengthInSeconds intValue];
    
    if (played != 0)
        return [NSString stringWithFormat:@"Duration: %@ / %@", [self stringFromDuration:played], [self stringFromDuration:duration]];

    return [NSString stringWithFormat:@"Duration: %@", [self stringFromDuration:duration]];
}

- (NSString *)stringFromDuration:(NSTimeInterval)duration {
    long seconds = lroundf(duration); // Modulo (%) operator below needs int or long
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;

    if (hour > 0)
        return [NSString stringWithFormat:@"%d:%02d:%02d", hour, mins, secs];
    return [NSString stringWithFormat:@"%d:%02d", mins, secs];
}

- (NSString *)bylineLabelText {
    NSDictionary *users = @{@"jeff": @"Jeff Gerstmann",
                              @"drewbert": @"Drew Scanlon",
                              @"vinny": @"Vinny Caravella",
                              @"patrickklepek": @"Patrick Klepek",
                              @"alex": @"Alex Navarro",
                              @"brad": @"Brad Shoemaker",
                              @"snide": @"Dave Snider",
                              @"mattbodega": @"Matthew Kessler",
                              @"marino": @"Marino",
                              @"ryan": @"Ryan Davis",
                              @"rorie": @"Matt Rorie",
                              @"abauman": @"Andy Bauman",
                              @"danielcomfort": @"Daniel Comfort"};
    
    if (users[self.video.user]) return users[self.video.user];
    return self.video.user;
}

//

#pragma mark - UITableViewDelegate protocol methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == kQualityCell) {
        self.pickerVisible = !self.pickerVisible;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // height for quality picker cell - hidden or visible
    if (indexPath.row == kQualityPickerCell) {
        if (self.pickerVisible)
            return 90;
        else
            return 0;
    } else if (indexPath.row == kVideoTitleCell) {
        // TODO: calculate this
        return 64;
    } else if (indexPath.row == kVideoBylineCell) {
        return 44;
    } else if (indexPath.row == kVideoDetailCell) {
//        return [[self class] heightOfCellWithIngredientLine:self.descriptionLabel.text
//                                         withSuperviewWidth:[UIScreen mainScreen].bounds.size.width];
        return self.descriptionLabel.bounds.size.height * 1.05;
    }
    return 44;
}

#pragma mark - UIScrollViewDelegate protocol methods

// used for Tweetbot-style image pulldown
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = -scrollView.contentOffset.y;
    if (y > 0) {
        self.imageView.frame = CGRectMake(0, scrollView.contentOffset.y, self.cachedImageViewSize.size.width+y, self.cachedImageViewSize.size.height+y);
        self.imageView.center = CGPointMake(self.view.center.x, self.imageView.center.y);
    }
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
    NSString *current = qualities[row];

    for (BWDownload *download in self.downloads) {
        if ([download.quality intValue] == row) {
            if (download.complete)
                current = [current stringByAppendingString:@" (downloaded)"];
            else
                current = [current stringByAppendingString:@" (downloading)"];
            break;
        }
    }

    return current;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self refreshViews];
}

#pragma mark - UIPickerViewDataSource protocol methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self isPremium])
        return 4;
    return 3;
}

- (BOOL)isPremium {
    return ![[self.video.videoHDURL absoluteString] isEqual: GiantBombVideoEmptyURL];
}

#pragma mark - Video player control

- (IBAction)playButtonPressed:(id)sender {
    [self playVideo];
}

- (void)playVideo {
    self.player = [[MPMoviePlayerViewController alloc] init];
    self.player.moviePlayer.fullscreen = YES;
    self.player.moviePlayer.allowsAirPlay = YES;

    NSURL *contentURL = [self videoURLForQuality:[self.qualityPicker selectedRowInComponent:0]];
    if ([contentURL isFileURL])
        self.player.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    else
        self.player.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
    NSNumber *playbackTime = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"][[NSString stringWithFormat:@"%@", self.video.videoID]];
    [self.player.moviePlayer setInitialPlaybackTime:[playbackTime doubleValue]];
    
    // TODO try using MPMoviePlayerDidExitFullscreenNotification instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedPlaying:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player.moviePlayer];
    
    self.player.moviePlayer.contentURL = contentURL;
    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}

- (void)movieFinishedPlaying: (NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.player.moviePlayer];

    NSMutableDictionary *progress = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] mutableCopy];
    NSNumber *playback = [NSNumber numberWithDouble:self.player.moviePlayer.currentPlaybackTime];
    NSString *key = [NSString stringWithFormat:@"%@", self.video.videoID];

    if (self.player.moviePlayer.currentPlaybackTime > 0) {
        if (self.player.moviePlayer.currentPlaybackTime >= (self.player.moviePlayer.duration * 0.95)) {
            [self.video setWatched];
            [progress removeObjectForKey:key];
        } else
            [progress setObject:playback forKey:key];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[progress copy] forKey:@"videoProgress"];
    self.durationLabel.text = [self durationLabelText];
    [self updateWatchedButton];
}

- (NSURL *)videoURLForQuality:(int)quality {
    NSURL *path;

    for (BWDownload *download in self.downloads) {
        if ([download.quality intValue] == quality && download.complete) {
            NSString *filename = [NSString stringWithFormat:@"%@-%d", download.videoID, [download.quality intValue]];
            NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            path = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp4", documentsPath, filename]];
            break;
        }
    }
    
    if (path == nil) {
        switch (quality) {
            case BWDownloadVideoQualityMobile:
                path = self.video.videoMobileURL; break;
            case BWDownloadVideoQualityLow:
                path = self.video.videoLowURL; break;
            case BWDownloadVideoQualityHigh:
                path = self.video.videoHighURL; break;
            case BWDownloadVideoQualityHD:
                path = self.video.videoHDURL; break;
            default:
                path = self.video.videoLowURL; break;
        }
    }

    return path;
}

#pragma mark - Action sheet

- (IBAction)actionButtonPressed:(id)sender {
    NSArray *activityItems = @[self.video, self.video.siteDetailURL];
    NSArray *applicationActivities;

    PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
    OpenOnGBActivity *gbActivity = [[OpenOnGBActivity alloc] init];
    applicationActivities = @[gbActivity, pocketActivity];
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:applicationActivities];

    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Favorites

- (IBAction)favoriteButtonPressed:(id)sender {
    // TODO: show image with status
    [SVProgressHUD showSuccessWithStatus:@"Favorited"];
}

#pragma mark - Downloads

- (IBAction)downloadButtonPressed:(id)sender {
    [[BWDownloadsDataStore defaultStore] createDownloadWithVideo:self.video
                                                         quality:[self.qualityPicker selectedRowInComponent:0]];
    [SVProgressHUD showSuccessWithStatus:@"Downloading"];
    [self refreshViews];
}

- (void)updateDownloadButton {
    int quality = [self.qualityPicker selectedRowInComponent:0];
    BOOL enabled = YES;

    for (BWDownload *download in self.downloads) {
        if ([download.quality intValue] == quality) {
            if (download.complete)
                self.downloadButton.image = [UIImage imageNamed:@"ToolbarDownloadFull"];
            else
                self.downloadButton.image = [UIImage imageNamed:@"ToolbarDownload"];
            enabled = NO;
            break;
        }
    }

    if (enabled)
        self.downloadButton.image = [UIImage imageNamed:@"ToolbarDownload"];
    
    self.downloadButton.enabled = enabled;
}

- (void)markDownloadProgress:(NSNotification *)notification {
//    NSDictionary *dict = [notification userInfo];
//    BWDownload *download = dict[@"download"];
//    GBVideo *video = (GBVideo *)download.video;
//    if ([video.videoID isEqualToNumber:self.video.videoID]) {
//        [self.progressView setProgress:[dict[@"progress"] floatValue] animated:YES];
//        self.progressView.hidden = NO;
//    }
}

- (void)markDownloadComplete:(NSNotification *)notification {
    [self refreshViews];
}

- (void)markDownloadError:(NSNotification *)notification {
    [self refreshViews];
}

#pragma mark - Watched status

- (IBAction)watchedButtonPressed:(id)sender {
    // TODO: show image with status
    if (![self.video isWatched]) {
        [self.video setWatched];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismiss)
                                                     name:SVProgressHUDDidDisappearNotification
                                                   object:nil];
        [SVProgressHUD showSuccessWithStatus:@"Watched"];
    } else {
        [self.video setUnwatched];
        [SVProgressHUD showSuccessWithStatus:@"Unwatched"];
    }

    [self updateWatchedButton];
}

- (void)updateWatchedButton {
    if ([self.video isWatched])
        self.watchedButton.image = [UIImage imageNamed:@"ToolbarCheckFull"];
    else
        self.watchedButton.image = [UIImage imageNamed:@"ToolbarCheck"];
}

#pragma mark - Utility

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SVProgressHUDDidDisappearNotification
                                                  object:nil];
}

- (void)refreshViews {
    [self refreshDownloadList];
    [self updateDownloadButton];
    [self updateWatchedButton];
    [self.qualityPicker reloadAllComponents];
    self.qualityLabel.text = [self pickerView:self.qualityPicker
                                  titleForRow:[self.qualityPicker selectedRowInComponent:0]
                                 forComponent:0];
    [self.tableView reloadData];
}

@end
