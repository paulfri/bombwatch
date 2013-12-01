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

@interface BWListViewController ()

@property (strong, nonatomic) UIView *disableOverlay;

@end

@implementation BWListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.category;
    self.listController = [[BWListController alloc] initWithTableView:self.tableView
                                                             category:self.category];
    self.listController.delegate = self;
    self.tableView.separatorColor  = [UIColor grayColor];
    
    CGRect f = self.tableView.frame;
    CGRect frame = CGRectMake(f.origin.x, f.origin.y + 44, f.size.width, f.size.height - 44);
    self.disableOverlay = [[UIView alloc] initWithFrame:frame];
    self.disableOverlay.backgroundColor = [UIColor blackColor];

    [self.tableView setContentOffset:CGPointMake(0,44) animated:YES];
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
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self searchBar:searchBar setActive:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.listController search:searchBar.text];
    [self searchBar:searchBar setActive:NO];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.searchBar isFirstResponder] && [touch view] != self.searchBar && ![self.searchBar.subviews containsObject:[touch view]])
    {
        [self searchBar:self.searchBar setActive:NO];
    }
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - util

- (void)searchBar:(UISearchBar *)searchBar setActive:(BOOL)active
{
    self.tableView.userInteractionEnabled = !active;
    
    if (!active) {
        [self.searchBar resignFirstResponder];
        [self.disableOverlay removeFromSuperview];
        [self.tableView setContentOffset:CGPointMake(0,44) animated:YES];
    } else {
        self.disableOverlay.alpha = 0;
        [self.tableView addSubview:self.disableOverlay];
        
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableOverlay.alpha = 0.6;
        [UIView commitAnimations]; // clean up this syntax
    }
}

@end
