//
//  BWCategoriesViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWCategoriesViewController.h"
#import "BWVideoListViewController.h"
#import "BWAppDelegate.h"

@interface BWCategoriesViewController ()

// TODO: this should be constantized somewhere
@property (strong, nonatomic) NSArray *videoCategories;

@end

@implementation BWCategoriesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Videos";

    // TODO: this should be constantized somewhere
    self.videoCategories = @[@"Latest", @"Quick Looks", @"Features", @"Events",
                             @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                             @"Premium"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource protocol methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoCategories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Categories";
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"CategoryCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    cell.textLabel.text = [self.videoCategories objectAtIndex:[indexPath row]];

    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BWVideoListViewController *destinationVC = (BWVideoListViewController *)[segue destinationViewController];

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
