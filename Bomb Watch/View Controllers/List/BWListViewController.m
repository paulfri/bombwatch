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
    self.listController = [[BWListController alloc] initWithTableView:self.tableView];
    
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.rowHeight = 65.0;
    self.tableView.allowsSelection = YES;
    self.tableView.enabled = YES;
    self.tableView.delegate = self;

    [self.listController loadVideos];
}

- (void)tableView:(PDGesturedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GBVideo *video = [self.listController videoAtIndexPath:indexPath];
    
    if (video) {
        [self performSegueWithIdentifier:@"kBWVideoDetailSegue" sender:video];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"kBWVideoDetailSegue"]) {
        BWVideoDetailViewController *controller = [segue destinationViewController];
        controller.video = sender;
    }
}

@end
