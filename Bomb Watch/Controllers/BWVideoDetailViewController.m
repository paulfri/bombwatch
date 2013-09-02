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
//#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PocketAPIActivity.h"
#import "PocketAPI.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"
#import "GiantBombAPIClient.h"
#import "EVCircularProgressView.h"
#import "BWDownloadsDataStore.h"
#import "BWDownload.h"

// default quality when no downloads are present
#define kDefaultQuality     BWDownloadVideoQualityLow
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pickerVisible = NO;
    
    self.titleLabel.text = self.video.name;
    self.descriptionLabel.text = self.video.summary;
    self.bylineLabel.text = [self bylineLabelText];
    self.durationLabel.text = [self durationLabelText];

    // Tweetbot-style image pulldown
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 180)];
//    self.imageView.backgroundColor = [UIColor blackColor];
    [self.imageView setImageWithURL:self.video.imageMediumURL placeholderImage:[UIImage imageNamed:@"VideoPlaceholder"]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.cachedImageViewSize = self.imageView.frame;
    [self.tableView addSubview:self.imageView];
    [self.tableView sendSubviewToBack:self.imageView];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 180)];

    // quality picker
    self.qualityPicker.delegate = self;
    self.qualityPicker.dataSource = self;
    [self.qualityPicker reloadAllComponents];

    // downloads
    [self selectBestQuality];
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
    
    [self refreshDownloadList];
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

- (void)refreshDownloadList {
    // TODO: consider refactoring this to only include completed downloads
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"videoID == %@", self.video.videoID];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"quality" ascending:NO]];
    self.downloads = [[[BWDownloadsDataStore defaultStore] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
}

- (void)selectBestQuality {
    [self refreshDownloadList];
    [self.qualityPicker reloadAllComponents];
    if (self.downloads.count > 0) {
        BWDownload *highestQualityDL = (BWDownload *)self.downloads[0];
        [self.qualityPicker selectRow:[highestQualityDL.quality intValue] inComponent:0 animated:NO];
        [self pickerView:self.qualityPicker didSelectRow:[highestQualityDL.quality intValue] inComponent:0];
    } else {
        [self.qualityPicker selectRow:kDefaultQuality inComponent:0 animated:NO];
        [self pickerView:self.qualityPicker didSelectRow:kDefaultQuality inComponent:0];
    }
}

- (NSString *)durationLabelText {
    NSTimeInterval duration = [self.video.lengthInSeconds intValue];
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
                              @"mattbodega": @"Matt Bodega",
                              @"marino": @"Marino",
                              @"ryan": @"Ryan Davis",
                              @"rorie": @"Matt Rorie",
                              @"abauman": @"Andy Bauman",
                              @"danielcomfort": @"Daniel Comfort"};
    
    if (users[self.video.user]) return users[self.video.user];
    return self.video.user;
}

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
        if ([download.quality intValue] == row && download.complete) {
            current = [current stringByAppendingString:@" (saved)"];
            break;
        }
    }

    return current;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
#warning make this update the download toolbar item to grey it out if it's already downloaded/downloading for the selected quality
    self.qualityLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
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

#pragma mark - IBActions

- (IBAction)playButtonPressed:(id)sender {
    self.player = [[MPMoviePlayerViewController alloc] init];

    NSURL *contentURL = [self videoURLForQuality:[self.qualityPicker selectedRowInComponent:0]];

//    [self.player.moviePlayer setFullscreen:YES animated:YES];
    self.player.moviePlayer.fullscreen = YES;
    self.player.moviePlayer.allowsAirPlay = YES;

    if ([contentURL isFileURL]) { // for downloaded
        self.player.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    } else { // for streamed
        self.player.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    }

    NSNumber *playbackTime = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"][[NSString stringWithFormat:@"%@", self.video.videoID]];
    [self.player.moviePlayer setInitialPlaybackTime:[playbackTime doubleValue]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedPlaying:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player.moviePlayer];

    self.player.moviePlayer.contentURL = contentURL;
    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}

-(void) movieFinishedPlaying: (NSNotification *) note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.player.moviePlayer];

    NSMutableDictionary *progress = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] mutableCopy];
    NSNumber *playback = [NSNumber numberWithDouble:self.player.moviePlayer.currentPlaybackTime];
    NSString *key = [NSString stringWithFormat:@"%@", self.video.videoID];

    if (self.player.moviePlayer.currentPlaybackTime >= self.player.moviePlayer.duration) {
        NSMutableArray *watched = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"videosWatched"] mutableCopy];
        [watched addObject:self.video.videoID];
        [[NSUserDefaults standardUserDefaults] setObject:watched forKey:@"videosWatched"];
        [progress removeObjectForKey:key];
    } else
        [progress setObject:playback forKey:key];

    [[NSUserDefaults standardUserDefaults] setObject:[progress copy] forKey:@"videoProgress"];
}

// TODO: make this take quality as an input
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
                // TODO: use mobile URL when avail
                path = self.video.videoLowURL;
                break;
            case BWDownloadVideoQualityLow:
                path = self.video.videoLowURL;
                break;
            case BWDownloadVideoQualityHigh:
                path = self.video.videoHighURL;
                break;
            case BWDownloadVideoQualityHD:
                path = self.video.videoHDURL;
                break;
            default: // not sure what happened
                path = self.video.videoLowURL;
                break;
        }
    }

    return path;
}

- (IBAction)actionButtonPressed:(id)sender {
    NSArray *activityItems;
    NSArray *applicationActivities;

    if([PocketAPI sharedAPI].loggedIn) {
        PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
        applicationActivities = @[pocketActivity];
    }

    activityItems = @[self.video];

    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:applicationActivities];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)favoriteButtonPressed:(id)sender {
    // TODO: show image with status
    [SVProgressHUD showSuccessWithStatus:@"Favorited"];
}

- (IBAction)watchedButtonPressed:(id)sender {
    // TODO: show image with status
    [SVProgressHUD showSuccessWithStatus:@"Watched"];
}

#pragma mark - Downloads

- (IBAction)downloadButtonPressed:(id)sender {
    [SVProgressHUD showSuccessWithStatus:@"Added to downloads"];
    self.progressView.hidden = NO;

    [[BWDownloadsDataStore defaultStore] createDownloadWithVideo:self.video
                                                         quality:[self.qualityPicker selectedRowInComponent:0]];
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
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    GBVideo *video = (GBVideo *)download.video;
    if ([video.videoID isEqualToNumber:self.video.videoID]) {
        [self selectBestQuality];
    }
}

- (void)markDownloadError:(NSNotification *)notification {
//    NSDictionary *dict = [notification userInfo];
//    BWDownload *download = dict[@"download"];
//    GBVideo *video = (GBVideo *)download.video;
//    if ([video.videoID isEqualToNumber:self.video.videoID]) {
//        [self.progressView setProgress:0 animated:NO];
//        self.progressView.hidden = NO;
//    }
}

//#pragma mark - something
//
//+ (CGFloat)heightOfCellWithIngredientLine:(NSString *)ingredientLine
//                       withSuperviewWidth:(CGFloat)superviewWidth
//{
//    CGFloat labelWidth                  = superviewWidth - 30.0f;
//    //    use the known label width with a maximum height of 100 points
//    CGSize labelContraints              = CGSizeMake(labelWidth, 100.0f);
//    
//    NSStringDrawingContext *context     = [[NSStringDrawingContext alloc] init];
//    
//    CGRect labelRect                    = [ingredientLine boundingRectWithSize:labelContraints
//                                                                       options:NSStringDrawingUsesLineFragmentOrigin
//                                                                    attributes:nil
//                                                                       context:context];
//    
//    //    return the calculated required height of the cell considering the label
//    return labelRect.size.height;
//}
@end
