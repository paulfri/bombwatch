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
        NSLog(@"logged in");
        PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
        applicationActivities = @[pocketActivity];
        NSLog(@"%@", pocketActivity);
    }

    // TODO: find a way to get the title into the PocketAPIActivity
    activityItems = @[self.video.videoLowURL];

    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:applicationActivities];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
