//
//  BWFavoritesViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWFavoritesViewController.h"
#import "BWVideo.h"
#import "BWVideoTableViewCell.h"
#import "BWVideoDetailViewController.h"

@interface BWFavoritesViewController ()

@property (strong, nonatomic) NSMutableArray *favorites;

@end

@implementation BWFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO add background view
    
    self.tableView.enabled = YES;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor  = [UIColor darkGrayColor];

    __unsafe_unretained typeof(self) _self = self;
    
    [self.tableView setDidMoveCellFromIndexPathToIndexPathBlock:^(NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath) {
        [_self.favorites exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        [BWVideo setFavorites:_self.favorites];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.favorites = [BWVideo favorites];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"kBWFavoritesCellIdentifier";
    
    BWVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[BWVideoTableViewCell alloc] initForGesturedTableView:self.tableView
                                                                style:UITableViewCellStyleDefault
                                                      reuseIdentifier:reuseIdentifier];

        __unsafe_unretained typeof(self) _self = self;
        void (^toggleFavorite)(PDGesturedTableView*, PDGesturedTableViewCell*) = ^(PDGesturedTableView *tableView, PDGesturedTableViewCell *cell)
        {
            BWVideoTableViewCell *videoCell = (BWVideoTableViewCell *)cell;
            BWVideo *video = [_self videoAtIndexPath:[tableView indexPathForCell:videoCell]];

            [tableView removeCell:cell completion:^{
                [video setFavorited:NO];
                _self.favorites = [BWVideo favorites];
            }];
        };

        PDGesturedTableViewCellSlidingFraction *favoriteFraction =
        [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                  color:[UIColor blackColor]
                                                     activationFraction:-0.15];
        
        [favoriteFraction setDidReleaseBlock:toggleFavorite];
        [cell addSlidingFraction:favoriteFraction];
    }
    
    BWVideo *video = [self videoAtIndexPath:indexPath];
    
    cell.textLabel.text = video.name;
    [cell setBackgroundImageWithURL:video.imageSmallURL];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favorites.count;
}

- (BWVideo *)videoAtIndexPath:(NSIndexPath *)indexPath
{
    return self.favorites[indexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWVideo *video = [self videoAtIndexPath:indexPath];
    
    if (video) {
        [self performSegueWithIdentifier:@"kBWFavoritesDetailSegue" sender:video];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"kBWFavoritesDetailSegue"]) {
        ((BWVideoDetailViewController *)segue.destinationViewController).video = sender;
    }
}

@end
