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

@protocol BWListControllerDelegate <NSObject>
@optional

- (void)videoSelected:(BWVideo *)video;
- (void)tableViewContentsReset;
- (void)searchDidCompleteWithSuccess;
- (void)searchDidCompleteWithFailure;

@end

@interface BWListController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) NSString *category;

@property (weak, nonatomic) PDGesturedTableView *tableView;
@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) id<BWListControllerDelegate> delegate;

- (id)initWithTableView:(PDGesturedTableView *)tableView category:(NSString *)category;
- (BWVideo *)videoAtIndexPath:(NSIndexPath *)indexPath;

- (void)search:(NSString *)text;

@end
