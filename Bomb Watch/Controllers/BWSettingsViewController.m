//
//  BWSettingsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWSettingsViewController.h"
#import "GiantBombAPIClient.h"
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
    [self setValues];
}

- (void)setValues {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![[defaults stringForKey:@"apiKey"] isEqualToString:GiantBombDefaultAPIKey]) {
        self.accountLinkedLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"];
    } else {
        self.accountLinkedLabel.text = @"Not Linked";
    }

    self.pocketSwitch.on = self.pocket.loggedIn;
    self.lockRotationSwitch.on = [defaults boolForKey:@"lockRotation"];
    self.showTrailersSwitch.on = [defaults boolForKey:@"showTrailersInLatest"];
    self.showPremiumSwitch.on = [defaults boolForKey:@"showPremiumInLatest"];
    self.versionDetailLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - IB Actions

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

#pragma mark - Link Giant Bomb account

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    if (cell == self.accountLinkedCell) {
//        [self linkAccount];
//    }
//}
//
//- (void)linkAccount {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link Account" message:@"giantbomb.com/boxee" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Link", nil];
//
//    [alert show];
//}

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
