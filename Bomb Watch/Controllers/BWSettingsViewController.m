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

#define kDefaultViewSection     2
#define kDefaultViewCell        4
#define kDefaultViewPickerCell  5

@interface BWSettingsViewController ()

@property (strong, nonatomic) PocketAPI *pocket;
@property (strong, nonatomic) NSArray *defaultViewOptions;
@property BOOL pickerVisible;

@end

@implementation BWSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pocket = [PocketAPI sharedAPI];

    self.defaultViewOptions = @[@"Videos", @"Latest", @"Quick Looks", @"Features", @"Trailers"];
    NSString *initialView = [[NSUserDefaults standardUserDefaults] stringForKey:@"initialView"];
    self.initialViewLabel.text = initialView;
    [self.initialViewPicker selectRow:[self.defaultViewOptions indexOfObject:initialView] inComponent:0 animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self updateValues];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)updateValues {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([self accountIsLinked]) {
        self.accountLinkedLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"];
        self.accountLinkedCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        self.accountLinkedCell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.accountLinkedLabel.text = @"Not Linked";
        self.accountLinkedCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.accountLinkedCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    self.pocketSwitch.on = self.pocket.loggedIn;
    self.lockRotationSwitch.on = [defaults boolForKey:@"lockRotation"];
    self.showTrailersSwitch.on = [defaults boolForKey:@"showTrailersInLatest"];
    self.showPremiumSwitch.on = [defaults boolForKey:@"showPremiumInLatest"];
    self.versionDetailLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (void)unlinkAccount {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"apiKey"];
}

- (BOOL)accountIsLinked {
    return ![[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] isEqualToString:GiantBombDefaultAPIKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.accountLinkedCell && [self accountIsLinked]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unlink"
                                                        message:@"Do you want to unlink your account?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yep", nil];
        alert.delegate = self;
        [alert show];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kDefaultViewSection && indexPath.row == kDefaultViewCell) {
        self.pickerVisible = !self.pickerVisible;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kDefaultViewPickerCell) {
        if (self.pickerVisible) return 162;
        else return 0;
    }
    return 44;
}

#pragma mark - UIAlertViewDelegate protocol methods

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [self unlinkAccount];
        [self updateValues];
    }
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

#pragma mark - Pocket

- (IBAction)pocketSwitchChanged:(id)sender {
    if(!self.pocket.loggedIn) {
        [SVProgressHUD showWithStatus:@"Logging in..."];
        [self pocketLogin];
    } else {
        [self pocketLogout];
    }
}

- (void)pocketLogin {
    [self.pocket loginWithHandler: ^(PocketAPI *API, NSError *error){
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:@"Login failed."];
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

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"linkAccountSegue"] && [self accountIsLinked]) {
        return NO;
    }
    return YES;
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.defaultViewOptions[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *initialView = [self pickerView:pickerView titleForRow:row forComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:initialView
                                              forKey:@"initialView"];
    self.initialViewLabel.text = initialView;
}

#pragma mark - UIPickerViewDataSource protocol methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.defaultViewOptions.count;
}


@end
