//
//  BWListViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWListViewController.h"
#import "BWVideoDetailViewController.h"
#import "BWVideo.h"

@implementation BWListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.category;
    self.listController = [[BWListController alloc] initWithTableView:self.tableView
                                                             category:self.category];
    self.listController.delegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor  = [UIColor grayColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"kBWVideoDetailSegue"]) {
        BWVideoDetailViewController *controller = [segue destinationViewController];
        controller.video = sender;
    }
}

- (void)videoSelected:(BWVideo *)video
{
    [self performSegueWithIdentifier:@"kBWVideoDetailSegue" sender:video];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedRow = [self.tableView indexPathsForSelectedRows].firstObject;
    [self.tableView reloadData];

    [self.tableView selectRowAtIndexPath:selectedRow
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    [self.tableView deselectRowAtIndexPath:selectedRow
                                  animated:YES];
}

@end
