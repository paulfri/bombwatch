//
//  BWSettingsViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *pocketSwitch;
- (IBAction)pocketSwitchToggled:(id)sender;

@end
