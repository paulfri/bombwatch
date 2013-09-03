//
//  BWSettingsViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWSettingsViewController : UITableViewController <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *pocketSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionDetailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showTrailersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showPremiumSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *lockRotationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *accountLinkedLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *accountLinkedCell;
@property (weak, nonatomic) IBOutlet UILabel *initialViewLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *initialViewPicker;

- (IBAction)pocketSwitchChanged:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)showTrailersSwitchChanged:(id)sender;
- (IBAction)showPremiumSwitchChanged:(id)sender;
- (IBAction)lockRotationSwitchChanged:(id)sender;

@end
