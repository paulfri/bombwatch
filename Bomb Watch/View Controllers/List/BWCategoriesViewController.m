//
//  BWCategoriesViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWCategoriesViewController.h"
#import "BWListViewController.h"
#import "BWAppDelegate.h"

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
    if (section == 0) {
        return self.featuredCategories.count;
    } else if (section == 1) {
        return self.enduranceRuns.count;
    } else {
        return self.otherCategories.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return  @[@"Featured", @"Endurance Run", @"Other"][section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CategoryCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if ([indexPath section] == 0) {
        cell.textLabel.text = [self.featuredCategories objectAtIndex:[indexPath row]];
    } else if ([indexPath section] == 1) {
        cell.textLabel.text = [self.enduranceRuns objectAtIndex:[indexPath row]];
    } else {
        cell.textLabel.text = [self.otherCategories objectAtIndex:[indexPath row]];
    }

    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BWListViewController *destinationVC = (BWListViewController *)[segue destinationViewController];

    if([[segue identifier] isEqualToString:@"videoListSegue"]) {
        if ([sender isKindOfClass:[NSString class]]) {
            // when this view is instantiated from the app delegate it doesn't seem to set its
            // title properly, which can mess up the nav controller's back button label
            self.title = @"Videos";
            destinationVC.category = sender;
        } else {
            UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
            destinationVC.category = selectedCell.textLabel.text;
        }
    }
}

@end
