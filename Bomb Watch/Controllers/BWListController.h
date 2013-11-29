//
//  BWListController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDGesturedTableView.h"
#import "GBVideo.h"

@interface BWListController : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *videos;
@property (weak, nonatomic) PDGesturedTableView *tableView;

- (id)initWithTableView:(PDGesturedTableView *)tableView;
- (GBVideo *)videoAtIndexPath:(NSIndexPath *)indexPath;
- (void)loadVideos;

@end
