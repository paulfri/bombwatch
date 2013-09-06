//
//  BWVideoDetailViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class GBVideo;

@interface BWVideoDetailViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) GBVideo *video;
@property (strong, nonatomic) UIImageView *imageView;
@property CGRect cachedImageViewSize;

@property (weak, nonatomic) IBOutlet UITableViewCell *qualityCell;
@property (strong, nonatomic) IBOutlet UIPickerView *qualityPicker;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bylineLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *watchedButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadButton;

// used for preloading the quality when coming from downloads view
@property (strong, nonatomic) NSNumber *preselectedQuality;

- (IBAction)actionButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)downloadButtonPressed:(id)sender;
- (IBAction)favoriteButtonPressed:(id)sender;
- (IBAction)watchedButtonPressed:(id)sender;

- (void)playVideo;

@end
