//
//  BWVideoPlayerViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BWDownloadDataStore.h"
#import "BWSettings.h"

#define kBWWatchedStatusThreshold 0.95
#define kBWMinimumStoredPlaybackTime 10.0

@implementation BWVideoPlayerViewController

- (id)initWithVideo:(BWVideo *)video
{
    self = [super init];

    if (self) {
        self.video = video;
        self.quality = [BWSettings defaultQuality];
    }

    return self;
}

- (id)initWithVideo:(BWVideo *)video quality:(BWVideoQuality)quality
{
    self = [super init];

    if (self) {
        self.video = video;
        self.quality = quality;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.allowsAirPlay = YES;
//    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;

    [self setContentURL];
    self.moviePlayer.initialPlaybackTime = [BWSettings progressForVideo:self.video];
    [self.moviePlayer prepareToPlay];
}

- (void)play
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteControlEventNotification:)
                                                 name:@"BWEventRemoteControlReceived"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedPlayingNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedPlayingNotification:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:self.moviePlayer];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession setMode:AVAudioSessionModeMoviePlayback error:nil];

    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{MPMediaItemPropertyTitle:self.video.name,
                                                              MPMediaItemPropertyArtist:@"Giant Bomb",
                                                              MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithInt:self.video.length]};;
    //    MPNowPlayingInfoPropertyElapsedPlaybackTime:@(self.moviePlayer.currentPlaybackTime)

    [self.moviePlayer play];
}

#pragma mark - Notification handlers

// This is forwarded by the app delegate
- (void)remoteControlEventNotification:(NSNotification *)notification
{
    UIEvent *event = notification.object;
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
                    [self.moviePlayer pause];
                else
                    [self.moviePlayer play];
                break;
            default:
                break;
        }
    }
}

- (void)movieFinishedPlayingNotification:(NSNotification *)notification
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BWEventRemoteControlReceived"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidExitFullscreenNotification
                                                  object:self.moviePlayer];

    BOOL watchedMinimally = (self.moviePlayer.currentPlaybackTime >= kBWMinimumStoredPlaybackTime);
    BOOL watchedEntirety  = (self.moviePlayer.currentPlaybackTime >= (self.moviePlayer.duration * kBWWatchedStatusThreshold));

    if (watchedMinimally && !watchedEntirety) {
        [BWSettings setWatchedProgress:self.moviePlayer.currentPlaybackTime forVideo:self.video];
    } else if (watchedEntirety) {
        [self.video setWatched:YES];
        [BWSettings removeWatchedProgressForVideo:self.video];
    }

    self.moviePlayer.fullscreen = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDidFinishPlaying)]) {
        [self.delegate videoDidFinishPlaying];
    }
}

#pragma mark - helpers

- (void)setContentURL
{
    NSURL *path;

    if ([[BWDownloadDataStore defaultStore] downloadExistsForVideo:self.video quality:self.quality]) {
        BWDownload *download = [[BWDownloadDataStore defaultStore] downloadForVideo:self.video quality:self.quality];

        if ([download isComplete]) {
            path = download.filePath;
        }
    }

    if (!path) {
        switch (self.quality) {
            case BWVideoQualityMobile:
                path = self.video.videoMobileURL; break;
            case BWVideoQualityHigh:
                path = self.video.videoHighURL; break;
            case BWVideoQualityHD:
                path = self.video.videoHDURL; break;
            case BWVideoQualityLow:
            default:
                path = self.video.videoLowURL; break;
        }
    }

    if ([path isFileURL]) {
        self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    } else {
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    }

    self.moviePlayer.contentURL = path;
}

#pragma mark - Interface orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([BWSettings lockRotation]) return UIInterfaceOrientationMaskLandscape;

    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
