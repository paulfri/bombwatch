//
//  BWSettingsViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWTableViewController.h"

@interface BWSettingsViewController : BWTableViewController <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *pocketSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionDetailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showTrailersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *lockRotationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *accountLinkedLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *accountLinkedCell;

@property (weak, nonatomic) IBOutlet UILabel *initialViewLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *initialViewPicker;

@property (weak, nonatomic) IBOutlet UIPickerView *defaultQualityPicker;
@property (weak, nonatomic) IBOutlet UILabel *defaultQualityLabel;

- (IBAction)pocketSwitchChanged:(id)sender;
- (IBAction)showTrailersSwitchChanged:(id)sender;
- (IBAction)lockRotationSwitchChanged:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
