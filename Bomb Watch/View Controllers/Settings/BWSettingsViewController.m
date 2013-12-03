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

#define kDefaultQualitySection    2
#define kDefaultQualityCell       2
#define kDefaultQualityPickerCell 3

@interface BWSettingsViewController ()

@property (strong, nonatomic) NSArray *defaultQualityOptions;
@property BOOL viewPickerVisible;
@property BOOL qualityPickerVisible;

@end

@implementation BWSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.accountLinkedLabel.textColor = [UIColor lightGrayColor];
    self.defaultQualityLabel.textColor = [UIColor lightGrayColor];
    self.versionDetailLabel.textColor = [UIColor lightGrayColor];

    self.defaultQualityOptions = @[@"Mobile", @"Low", @"High", @"HD"];
    NSString *defaultQuality = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuality"];
    self.defaultQualityLabel.text = defaultQuality;
    [self.defaultQualityPicker selectRow:[self.defaultQualityOptions indexOfObject:defaultQuality] inComponent:0 animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self updateValues];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (void)updateValues
{
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

    self.pocketSwitch.on = [PocketAPI sharedAPI].loggedIn;
    self.lockRotationSwitch.on = [defaults boolForKey:@"lockRotation"];
    self.versionDetailLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (void)unlinkAccount
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"apiKey"];
}

- (BOOL)accountIsLinked
{
    return ![[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] isEqualToString:kBWDefaultAPIKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDefaultQualitySection && indexPath.row == kDefaultQualityCell) {
        self.qualityPickerVisible = !self.qualityPickerVisible;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kDefaultQualityPickerCell) {
        if (self.qualityPickerVisible) {
            return 162;
        } else {
            return 0;
        }
    }

    return 44;
}

#pragma mark - UIAlertViewDelegate protocol methods

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self unlinkAccount];
        [self updateValues];
    }
}

#pragma mark - IB Actions

- (IBAction)lockRotationSwitchChanged:(id)sender
{
    UISwitch *control = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:control.on forKey:@"lockRotation"];
}

- (void)donePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Pocket

- (IBAction)pocketSwitchChanged:(id)sender
{
    if(![PocketAPI sharedAPI].loggedIn) {
        [SVProgressHUD showWithStatus:@"Logging in..."];
        [self pocketLogin];
    } else {
        [self pocketLogout];
    }
}

- (void)pocketLogin
{
    [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:@"Login failed."];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"Logged in!"];
        }

        self.pocketSwitch.on = [PocketAPI sharedAPI].loggedIn;
    }];
}

- (void)pocketLogout
{
    [[PocketAPI sharedAPI] logout];
    [SVProgressHUD showSuccessWithStatus:@"Logged out"];
    self.pocketSwitch.on = NO;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"linkAccountSegue"] && [self accountIsLinked]) {
        return NO;
    }

    return YES;
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.defaultQualityPicker) {
        NSString *defaultQuality = [[self pickerView:pickerView attributedTitleForRow:row forComponent:component] string];
        [[NSUserDefaults standardUserDefaults] setObject:defaultQuality forKey:@"defaultQuality"];
        self.defaultQualityLabel.text = defaultQuality;
    }
}

#pragma mark - UIPickerViewDataSource protocol methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.defaultQualityPicker) {
        return self.defaultQualityOptions.count;
    }

    return 0;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString:self.defaultQualityOptions[row]
                                           attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


@end
