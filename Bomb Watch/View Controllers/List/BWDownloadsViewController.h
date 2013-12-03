//
//  BWDownloadsViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/2/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDGesturedTableView.h"

@interface BWDownloadsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet PDGesturedTableView *tableView;

@end
