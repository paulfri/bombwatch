//
//  BWSettingsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWSettingsViewController.h"
#import "PocketAPI.h"
#import "SVProgressHUD.h"

@interface BWSettingsViewController ()

@property (strong, nonatomic) PocketAPI *pocket;

@end

@implementation BWSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Settings"];

    self.pocket = [PocketAPI sharedAPI];
    [self setCurrentValues];
}

- (void)setCurrentValues {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.pocketSwitch.on = self.pocket.loggedIn;
    self.lockRotationSwitch.on = [defaults boolForKey:@"lockRotation"];
    self.showTrailersSwitch.on = [defaults boolForKey:@"showTrailersInLatest"];
    self.showPremiumSwitch.on = [defaults boolForKey:@"showPremiumInLatest"];

    self.versionDetailLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showTrailersSwitchChanged:(id)sender {
    UISwitch *control = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:control.on forKey:@"showTrailersInLatest"];
}

- (IBAction)showPremiumSwitchChanged:(id)sender {
    UISwitch *control = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:control.on forKey:@"showPremiumInLatest"];
}

- (IBAction)lockRotationSwitchChanged:(id)sender {
    UISwitch *control = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:control.on forKey:@"lockRotation"];
}

#pragma mark - Pocket

- (IBAction)pocketSwitchChanged:(id)sender {
    if(!self.pocket.loggedIn) {
        // switch to KVO for the login UI if this doesn't seem reliable
        [SVProgressHUD showWithStatus:@"Logging in..."];
        [self pocketLogin];
    } else {
        [self pocketLogout];
    }
}

- (void)pocketLogin {
    [self.pocket loginWithHandler: ^(PocketAPI *API, NSError *error){
        if (error != nil) {
            // The error object will contain a human readable error message that you
            // should display to the user. Ex: Show an UIAlertView with the message
            // from error.localizedDescription
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"Logged in!"];
        }

        self.pocketSwitch.on = self.pocket.loggedIn;
    }];
}

- (void)pocketLogout {
    [self.pocket logout];
    [SVProgressHUD showSuccessWithStatus:@"Logged out"];
    self.pocketSwitch.on = NO;
}

@end
