//
//  BWListViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDGesturedTableView.h"
#import "BWListController.h"

@interface BWListViewController : UIViewController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet PDGesturedTableView *tableView;
@property (strong, nonatomic) BWListController *listController;

@end
