//
//  BWDownloadsViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDGesturedTableView.h"
#import "BWVideoSelectionDelegate.h"

@interface BWDownloadsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet PDGesturedTableView *tableView;
@property (strong, nonatomic) id<BWVideoSelectionDelegate> delegate;

@end
