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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return @"Test!!";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //
}

#pragma mark - UIPickerViewDataSource protocol methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

#pragma mark - Navigation

/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}
*/

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
    [self startDownload];
}

- (void)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.video.videoLowURL];
    NSString *relativePath = [NSString stringWithFormat:@"Documents/%@", self.video.videoID];

    // TODO: add file format
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:relativePath];

    __block BWDownload *download = [[BWDownloadsDataStore defaultStore] createDownloadWithVideo:self.video];
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                                                     targetPath:path
                                                                                   shouldResume:YES];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Done downloading %@", path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %ld", (long)[error code]);
    }];

    // can i set this later???
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        float progress = ((float)totalBytesReadForFile) / totalBytesExpectedToReadForFile;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoProgressUpdateNotification"
                                                            object:self
                                                          userInfo:@{@"download": download,
                                                                     @"progress": [NSNumber numberWithFloat:progress],
                                                                     @"path": download.path}];
    }];

    [[GiantBombAPIClient defaultClient] enqueueHTTPRequestOperation:operation];
}

@end
