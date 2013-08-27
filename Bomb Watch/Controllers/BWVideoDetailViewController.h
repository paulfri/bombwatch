//
//  BWVideoDetailViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBVideo;

@interface BWVideoDetailViewController : UITableViewController

@property (strong, nonatomic) GBVideo *video;

- (IBAction)playButtonPressed:(id)sender;

@end
