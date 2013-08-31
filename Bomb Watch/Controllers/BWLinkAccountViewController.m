//
//  BWLinkAccountViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWLinkAccountViewController.h"
#import "GiantBombAPIClient.h"
#import "SVProgressHUD.h"

@interface BWLinkAccountViewController ()

@end

@implementation BWLinkAccountViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.accountCode.delegate = self;
    self.accountCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.accountCode.autocorrectionType = UITextAutocorrectionTypeNo;
    self.accountCode.enablesReturnKeyAutomatically = NO;
    [self.accountCode becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    self.accountCode.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)savePressed:(id)sender {
    NSDictionary *params = @{@"link_code": self.accountCode.text};
    
    [SVProgressHUD showWithStatus:@"Linking..."];
    [[GiantBombAPIClient defaultClient] GET:@"validate" parameters:params success:^(NSHTTPURLResponse *response, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSLog(@"%@", responseObject);
        // TODO: check that apikey actually gets returned so we don't get a runtime crash
        // TODO: check that the api key is valid? maybe length? maybe do a test request? (prob not)
        NSString *apiKey = responseDict[@"api_key"];
        if ([apiKey isKindOfClass:[NSString class]] && [apiKey length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"apiKey"];
            [SVProgressHUD showSuccessWithStatus:@"Linked!"];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(dismiss)
                                                         name:SVProgressHUDDidDisappearNotification
                                                       object:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Link failed!"];
        }

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Link failed!"];
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;

    return newLength <= LINK_CODE_LENGTH || returnKey;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self savePressed:nil];
    return YES;
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
