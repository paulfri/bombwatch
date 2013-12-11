//
//  BWCategoriesViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWCategoriesViewController.h"
#import "BWListViewController.h"
#import "BWSegues.h"
#import "BWColors.h"

#define IS_IPAD  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define kBWMetaSection (IS_IPAD ? 0 : 999)
#define kBWFeaturedCategoriesSection (IS_IPAD ? 1 : 0)
#define kBWEnduranceRunSection (IS_IPAD ? 2 : 1)

NSString *const kBWCategoryCell = @"kBWCategoryCell";

@interface BWCategoriesViewController ()

// TODO: this should be constantized somewhere
@property (strong, nonatomic) NSArray *featuredCategories;
@property (strong, nonatomic) NSArray *enduranceRuns;
@property (strong, nonatomic) NSArray *meta;

@end

@implementation BWCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.meta = @[@"Favorites", @"Downloads"];
    self.featuredCategories = @[@"Latest", @"Quick Looks", @"Features", @"Events", @"Trailers", @"Subscriber"];
    self.enduranceRuns = @[@"Persona 4", @"The Matrix Online", @"Deadly Premonition", @"Chrono Trigger"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - UITableViewDataSource protocol methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return IS_IPAD ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kBWFeaturedCategoriesSection) {
        return self.featuredCategories.count;
    } else if (section == kBWEnduranceRunSection) {
        return self.enduranceRuns.count;
    } else if (section == kBWMetaSection) {
        return 2;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!IS_IPAD) {
        return @[@"Featured", @"Endurance Run"][section];
    } else {
        return @[@"Sections", @"Featured", @"Endurance Run"][section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.section == kBWFeaturedCategoriesSection || indexPath.section == kBWEnduranceRunSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"kBWCategoryCellIdentifier"];
    } else {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"kBWFavoritesCellIdentifier"];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"kBWDownloadsCellIdentifier"];
        }
    }

    if ([indexPath section] == kBWFeaturedCategoriesSection) {
        cell.textLabel.text = self.featuredCategories[indexPath.row];
    } else if ([indexPath section] == kBWEnduranceRunSection) {
        cell.textLabel.text = self.enduranceRuns[indexPath.row];
    } else if ([indexPath section] == kBWMetaSection) {
        cell.textLabel.text = self.meta[indexPath.row];
    }

    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BWListViewController *destinationVC = (BWListViewController *)[segue destinationViewController];

    if([[segue identifier] isEqualToString:kBWSegueVideoList]) {
        if ([sender isKindOfClass:[NSString class]]) {
            destinationVC.category = sender;
        } else {
            UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
            destinationVC.category = selectedCell.textLabel.text;
        }
    }
}

@end
