//
//  BWVideoPlayerViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kBWWatchedStatusThreshold 0.95

@interface BWVideoPlayerViewController ()

@property (strong, nonatomic) NSArray *downloads;

@end

@implementation BWVideoPlayerViewController

- (id)initWithVideo:(BWVideo *)video {
    self = [super init];
    if (self) {
        self.video = video;
    }
    return self;
}

- (id)initWithVideo:(BWVideo *)video quality:(NSInteger)quality downloads:(NSArray *)downloads {
    self = [super init];
    if (self) {
        self.video = video;
        self.quality = [NSNumber numberWithInt:quality];
        self.downloads = downloads;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.allowsAirPlay = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteControlEventNotification:)
                                                 name:@"BWEventRemoteControlReceived"
                                               object:nil];

    [self setContentURL];
}

- (void)play {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedPlayingNotification:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:self.moviePlayer];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self becomeFirstResponder];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession setMode:AVAudioSessionModeMoviePlayback error:nil];
    
    NSDictionary *nowPlayingInfo = @{MPMediaItemPropertyTitle:self.video.name,
                                     MPMediaItemPropertyArtist:@"Giant Bomb",
                                     MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithInt:self.video.length]};
    //    MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:self.moviePlayer.currentPlaybackTime]
    //    MPMediaItemPropertyArtwork

    self.moviePlayer.initialPlaybackTime = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"]
                                             objectForKey:[NSString stringWithFormat:@"%d", self.video.videoID]] doubleValue];
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
    [self.moviePlayer play];
}

#pragma mark - Notification handlers

// This is forwarded by the app delegate
- (void)remoteControlEventNotification:(NSNotification *)notification {
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

- (void)movieFinishedPlayingNotification:(NSNotification *)notification {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayer];

    NSMutableDictionary *progress = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] mutableCopy];
    NSNumber *playback = [NSNumber numberWithDouble:self.moviePlayer.currentPlaybackTime];
    NSString *key = [NSString stringWithFormat:@"%d", self.video.videoID];
    
    if (self.moviePlayer.currentPlaybackTime > 0) {
        if (self.moviePlayer.currentPlaybackTime >= (self.moviePlayer.duration * kBWWatchedStatusThreshold)) {
            [self.video setWatched:YES];
            [progress removeObjectForKey:key];
        } else
            [progress setObject:playback forKey:key];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[progress copy] forKey:@"videoProgress"];
    [self dismissMoviePlayerViewControllerAnimated];

    [self.delegate videoDidFinishPlaying];
}

#pragma mark - helpers

- (void)setContentURL
{
    NSURL *path;

    if (path == nil) {
        if (self.quality == nil) {
            NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
            int qual = [qualities indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuality"]];
            if (qual >= BWVideoQualityMobile && BWVideoQualityHD <= 3)
                self.quality = [NSNumber numberWithInt:qual];
        }
        
        switch ([self.quality intValue]) {
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
    BOOL landscapeLock = [[NSUserDefaults standardUserDefaults] boolForKey:@"lockRotation"];

    if (landscapeLock) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

@end
