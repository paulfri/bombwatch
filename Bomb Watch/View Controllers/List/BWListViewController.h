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
#import "BWVideoSelectionDelegate.h"

@interface BWListViewController : UIViewController <BWVideoPlayerDelegate, BWListControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSString *category;
@property (weak, nonatomic) IBOutlet PDGesturedTableView *tableView;
@property (strong, nonatomic) BWListController *listController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) id<BWVideoSelectionDelegate> delegate;

@end
