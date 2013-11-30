//
//  BWFavoritesViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDGesturedTableView.h"

@interface BWFavoritesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet PDGesturedTableView *tableView;

@end
