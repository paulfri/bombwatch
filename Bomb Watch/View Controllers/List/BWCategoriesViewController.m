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

#define kBWFeaturedCategoriesSection 0
#define kBWEnduranceRunSection 1
#define kBWOtherCategoriesSection 2

@interface BWCategoriesViewController ()

// TODO: this should be constantized somewhere
@property (strong, nonatomic) NSArray *featuredCategories;
@property (strong, nonatomic) NSArray *enduranceRuns;
@property (strong, nonatomic) NSArray *otherCategories;

@end

@implementation BWCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.featuredCategories = @[@"Latest", @"Quick Looks", @"Features", @"Events", @"Trailers"];
    self.enduranceRuns = @[@"Persona 4", @"The Matrix Online", @"Deadly Premonition", @"Chrono Trigger"];
    self.otherCategories = @[@"TANG", @"Reviews", @"Subscriber"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDataSource protocol methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kBWFeaturedCategoriesSection) {
        return self.featuredCategories.count;
    } else if (section == kBWEnduranceRunSection) {
        return self.enduranceRuns.count;
    } else if (section == kBWOtherCategoriesSection) {
        return self.otherCategories.count;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return  @[@"Featured", @"Endurance Run", @"Other"][section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CategoryCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if ([indexPath section] == kBWFeaturedCategoriesSection) {
        cell.textLabel.text = self.featuredCategories[indexPath.row];
    } else if ([indexPath section] == kBWEnduranceRunSection) {
        cell.textLabel.text = self.enduranceRuns[indexPath.row];
    } else if ([indexPath section] == kBWOtherCategoriesSection) {
        cell.textLabel.text = self.otherCategories[indexPath.row];
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
