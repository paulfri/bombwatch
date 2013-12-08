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
#import "BWVideoDataStore.h"
#import "BWSettings.h"

#define kBWLinkCodeLength 6
#define kBWAPIKeyLength 40

@implementation BWLinkAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.accountCode.delegate = self;
    self.accountCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.accountCode.autocorrectionType = UITextAutocorrectionTypeNo;
    self.accountCode.enablesReturnKeyAutomatically = NO;
    [self.accountCode becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.accountCode.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (IBAction)savePressed:(id)sender
{
    [SVProgressHUD showWithStatus:@"Linking..."];
    // TODO refactor this API call out of the view controller
    [[GiantBombAPIClient defaultClient] GET:@"validate"
                                 parameters:@{@"link_code": self.accountCode.text}
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        // TODO: check that a working API key actually gets returned
        NSString *apiKey = responseDict[@"api_key"];
        if ([apiKey isKindOfClass:[NSString class]] && [apiKey length] == kBWAPIKeyLength) {
            [BWSettings setAPIKey:apiKey];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(dismiss)
                                                         name:SVProgressHUDDidDisappearNotification
                                                       object:nil];
            [SVProgressHUD showSuccessWithStatus:@"Linked!"];
            [[BWVideoDataStore defaultStore] refreshAllCaches];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Link failed!"];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Link failed!"];
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL lowercase;
    NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if (lowercaseCharRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:[string uppercaseString]];
        lowercase = NO;
    } else {
        lowercase = YES;
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;

    return (newLength <= kBWLinkCodeLength && lowercase) || returnKey;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self savePressed:nil];
    return YES;
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:SVProgressHUDDidDisappearNotification
                                               object:nil];
}

@end
