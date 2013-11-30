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
#import "GiantBombAPIClient.h"
//#import "EVCircularProgressView.h"
#import "OpenOnGBActivity.h"
#import "BWSeparatorView.h"
#import "BWVideoPlayerViewController.h"

// default quality when no downloads are present
#define kQualityCell        1
#define kQualityPickerCell  2
#define kVideoTitleCell     3
#define kVideoBylineCell    4
#define kVideoDetailCell    5

@interface BWVideoDetailViewController ()

@property (strong, nonatomic) BWVideoPlayerViewController *player;
@property BOOL pickerVisible;

@end

@implementation BWVideoDetailViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self drawImagePulldown];

    self.titleLabel.text = self.video.name;
    self.descriptionLabel.text = self.video.summary;
    self.bylineLabel.text = [self bylineLabelText];
    [self updateDurationLabel];
    
    BWSeparatorView *view = [[BWSeparatorView alloc] initWithFrame:CGRectMake(20, 43, 300, 1/[[UIScreen mainScreen] scale])];
    view.backgroundColor = UIColorFromRGB(0xc8c7cc);
    view.selectColor = UIColorFromRGB(0xd9d9d9);
    [self.qualityCell addSubview:view];
}

// Tweetbot-style image pulldown
- (void)drawImagePulldown
{
    self.imagePulldownView = [[BWImagePulldownView alloc] initWithTitle:self.video.name
                                                               imageURL:self.video.imageMediumURL];
    self.tableView.tableHeaderView = self.imagePulldownView;
    [self.tableView sendSubviewToBack:self.tableView.tableHeaderView];
    
//    self.tableView.tableHeaderView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonPressed:)];
//    [self.tableView.tableHeaderView addGestureRecognizer:tapped];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.preselectedQuality)
        [self selectQuality:[self.preselectedQuality intValue]];
    else
        [self selectBestQuality];
    [self refreshViews];
}

- (void)selectBestQuality {
    [self selectQuality:[self defaultQuality]];
}

- (void)selectQuality:(int)quality {
    [self.qualityPicker selectRow:quality inComponent:0 animated:NO];
    [self pickerView:self.qualityPicker didSelectRow:quality inComponent:0];
}

- (NSInteger)defaultQuality {
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
    int qual = [qualities indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuality"]];
    if (qual >= 0 && qual <= 3)
        return qual;
//    return BWDownloadVideoQualityLow;
    return 1;
}

- (void)updateDurationLabel {
    NSTimeInterval played = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] objectForKey:[NSString stringWithFormat:@"%@", self.video.videoID]] doubleValue];
    NSTimeInterval duration = [self.video.lengthInSeconds intValue];
    
    if (played != 0)
        self.durationLabel.text = [NSString stringWithFormat:@"Duration: %@ / %@", [self stringFromDuration:played], [self stringFromDuration:duration]];
    else
        self.durationLabel.text = [NSString stringWithFormat:@"Duration: %@", [self stringFromDuration:duration]];
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
        return [self.titleLabel sizeThatFits:self.titleLabel.frame.size].height + 10;
    } else if (indexPath.row == kVideoBylineCell) {
        return 40;
    } else if (indexPath.row == kVideoDetailCell) {
        return [self.descriptionLabel sizeThatFits:self.descriptionLabel.frame.size].height + 10;
    }
    return 44;
}

#pragma mark - UIScrollViewDelegate protocol methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.imagePulldownView scrollViewDidScroll:scrollView];
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
    NSString *current = qualities[row];

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
    return ![[self.video.videoHDURL absoluteString] isEqual:GiantBombVideoEmptyURL];
}

#pragma mark - Video player control

- (IBAction)playButtonPressed:(id)sender {
    self.player = [[BWVideoPlayerViewController alloc] initWithVideo:self.video
                                                             quality:[self.qualityPicker selectedRowInComponent:0]
                                                           downloads:nil];
    self.player.delegate = self;
    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player play];
}

#pragma mark - BWVideoPlayerDelegate protocol methods

- (void)videoDidFinishPlaying {
    [self updateWatchedButton];
    [self updateDurationLabel];
}

#pragma mark - Action sheet

- (IBAction)actionButtonPressed:(id)sender
{
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
    [SVProgressHUD showSuccessWithStatus:@"Downloading"];
}

- (void)updateDownloadButton {
    BOOL enabled = YES;

    if (enabled)
        self.downloadButton.image = [UIImage imageNamed:@"ToolbarDownload"];
    
    self.downloadButton.enabled = enabled;
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
    [self updateDownloadButton];
    [self updateWatchedButton];
    [self.qualityPicker reloadAllComponents];
    self.qualityLabel.text = [self pickerView:self.qualityPicker
                                  titleForRow:[self.qualityPicker selectedRowInComponent:0]
                                 forComponent:0];
    [self.tableView reloadData];
}

@end
