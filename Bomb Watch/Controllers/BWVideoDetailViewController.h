//
//  BWVideoDetailViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBVideo;

@interface BWVideoDetailViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) GBVideo *video;
@property (weak, nonatomic) IBOutlet UIPickerView *qualityPicker;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)actionButtonPressed:(id)sender;
- (IBAction)downloadButtonPressed:(id)sender;

@end
