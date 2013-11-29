//
//  BWLinkAccountViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWLinkAccountViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountCode;

- (IBAction)savePressed:(id)sender;

@end
