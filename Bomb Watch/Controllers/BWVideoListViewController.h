//
//  BWVideoListViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    PER_PAGE = 25,
};

@interface BWVideoListViewController : UITableViewController

@property (strong, nonatomic) NSString *category;

@end
