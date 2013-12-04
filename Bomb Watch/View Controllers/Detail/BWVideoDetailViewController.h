//
//  BWVideoDetailViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWVideoPlayerDelegate.h"
@class BWImagePulldownView;
@class BWVideo;

@interface BWVideoDetailViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, BWVideoPlayerDelegate>

@property (strong, nonatomic) BWVideo *video;
@property (strong, nonatomic) NSMutableArray *downloads;

@property (strong, nonatomic) BWImagePulldownView *imagePulldownView;

@property (weak, nonatomic) IBOutlet UITableViewCell *bylineCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *durationCell;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *qualityCell;
@property (strong, nonatomic) IBOutlet UIPickerView *qualityPicker;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *watchedButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *downloadButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoritedButton;

- (IBAction)actionButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)downloadButtonPressed:(id)sender;
- (IBAction)favoriteButtonPressed:(id)sender;
- (IBAction)watchedButtonPressed:(id)sender;

@end
