//
//  BWSettingsViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWSettingsViewController.h"
#import "PocketAPI.h"

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pocketLoginStarted:)
                                                 name:@"PocketAPILoginStartedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pocketLoginFinished:)
                                                 name:@"PocketAPILoginFinishedNotification"
                                               object:nil];

    self.pocket = [PocketAPI sharedAPI];
    self.pocketSwitch.on = self.pocket.loggedIn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pocketSwitchToggled:(id)sender {
    if(!self.pocket.loggedIn) {
        [self pocketLogin];
    } else {
        [self pocketLogout];
    }

}

- (void)pocketLogin {
    [self.pocket loginWithHandler: ^(PocketAPI *API, NSError *error){
        if (error != nil) {
            // There was an error when authorizing the user.
            // The most common error is that the user denied access to your application.
            // The error object will contain a human readable error message that you
            // should display to the user. Ex: Show an UIAlertView with the message
            // from error.localizedDescription
            NSLog(@"%@", error.localizedDescription);
        } else {
            // The user logged in successfully, your app can now make requests.
            // [API username] will return the logged-in user’s username
            // and API.loggedIn will == YES
            NSLog(@"%@", [self.pocket username]);
        }
        
        self.pocketSwitch.on = self.pocket.loggedIn;
    }];
}

- (void)pocketLogout {
    [self.pocket logout];
    self.pocketSwitch.on = NO;
}

- (void)pocketLoginStarted:(NSNotification *)notification {
    NSLog(@"login start");
}

- (void)pocketLoginFinished:(NSNotification *)notification {
    NSLog(@"login finito");
}

@end
