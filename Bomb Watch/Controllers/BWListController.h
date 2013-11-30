//
//  BWListController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDGesturedTableView.h"
#import "BWVideo.h"
#import "BWListControllerDelegate.h"

@interface BWListController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) PDGesturedTableView *tableView;
@property (assign, nonatomic) NSInteger page;
@property (weak, nonatomic) id<BWListControllerDelegate> delegate;

- (id)initWithTableView:(PDGesturedTableView *)tableView;
- (id)initWithTableView:(PDGesturedTableView *)tableView category:(NSString *)category;
- (BWVideo *)videoAtIndexPath:(NSIndexPath *)indexPath;

@end
