//
//  BWListViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWListViewController.h"
#import "BWVideoDetailViewController.h"
#import "GBVideo.h"

@implementation BWListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.category;
    self.listController = [[BWListController alloc] initWithTableView:self.tableView
                                                             category:self.category];
    self.listController.delegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"kBWVideoDetailSegue"]) {
        BWVideoDetailViewController *controller = [segue destinationViewController];
        controller.video = sender;
    }
}

- (void)videoSelected:(GBVideo *)video
{
    [self performSegueWithIdentifier:@"kBWVideoDetailSegue" sender:video];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathsForSelectedRows].firstObject
                                  animated:NO];
}

@end
