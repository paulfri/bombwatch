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

@interface BWVideoDetailViewController ()

@property (strong, nonatomic) MPMoviePlayerViewController *player;
@property (strong, nonatomic) NSArray *downloads;

@end

@implementation BWVideoDetailViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:self.video.name];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.titleLabel.text = self.video.name;
    [self.previewImage setImageWithURL:self.video.imageMediumURL placeholderImage:[UIImage imageNamed:@"VideoPlaceholder"]];

//    self.progressView.hidden = YES;
    
    self.qualityPicker.delegate = self;
    self.qualityPicker.dataSource = self;
    [self.qualityPicker reloadAllComponents];

    [self refreshDownloadList];
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
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"videoID == %@", self.video.videoID];
    self.downloads = [[[BWDownloadsDataStore defaultStore] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
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
            current = [current stringByAppendingString:@" [DL]"];
            break;
        }
    }

    return current;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //
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
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:self.video.videoLowURL];

    [self.player.moviePlayer setFullscreen:YES animated:YES];
    [self.player.moviePlayer setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.player.moviePlayer setControlStyle:MPMovieSourceTypeStreaming];
    [self.player.moviePlayer setAllowsAirPlay:YES];
    [self.player.moviePlayer setContentURL:self.video.videoLowURL];
    // [self.player.moviePlayer setInitialPlaybackTime:NSTimeInterval]

    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];

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

#pragma mark - Downloads

- (IBAction)downloadButtonPressed:(id)sender {
    [SVProgressHUD showSuccessWithStatus:@"Added to downloads"];
    self.progressView.hidden = NO;

    [[BWDownloadsDataStore defaultStore] createDownloadWithVideo:self.video
                                                         quality:[self.qualityPicker selectedRowInComponent:0]];
}

- (void)markDownloadProgress:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    GBVideo *video = (GBVideo *)download.video;
    if ([video.videoID isEqualToNumber:self.video.videoID]) {
        [self.progressView setProgress:[dict[@"progress"] floatValue] animated:YES];
        self.progressView.hidden = NO;
    }
}

- (void)markDownloadComplete:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    GBVideo *video = (GBVideo *)download.video;
    if ([video.videoID isEqualToNumber:self.video.videoID]) {
        [self.progressView setProgress:0 animated:NO];
        self.progressView.hidden = YES;
    }
    [self refreshDownloadList];
    [self.qualityPicker reloadAllComponents];
}

- (void)markDownloadError:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    BWDownload *download = dict[@"download"];
    GBVideo *video = (GBVideo *)download.video;
    if ([video.videoID isEqualToNumber:self.video.videoID]) {
        [self.progressView setProgress:0 animated:NO];
        self.progressView.hidden = NO;
    }
}

@end
