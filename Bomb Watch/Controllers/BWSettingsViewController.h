//
//  BWSettingsViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWSettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *pocketSwitch;

- (IBAction)pocketSwitchChanged:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
