//
//  BWCategoriesViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/28/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWCategoriesViewController.h"
#import "BWVideoListViewController.h"

@interface BWCategoriesViewController ()

// TODO: this should be constantized somewhere
@property (strong, nonatomic) NSArray *videoCategories;

@end

@implementation BWCategoriesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Videos"];

    // TODO: this should be constantized somewhere
    self.videoCategories = @[@"Latest", @"Quick Looks", @"Features", @"Events",
                             @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                             @"Premium"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource protocol methods

/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 // 1 for now, which is the default implementation
 return 1;
 }
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // revisit this if I put more sections in
    return self.videoCategories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"Categories";
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"CategoryCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // TODO: do I have to use a custom cell for this? the default one is probably fine
    // add icons here later -- yeah just use the default cell coz it has an imageview already
    cell.textLabel.text = [self.videoCategories objectAtIndex:[indexPath row]];

    return cell;
}

#pragma mark - UITableViewDelegate protocol methods

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
*/

// this section intentionally left blank

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"videoListSegue"]) {
        BWVideoListViewController *destinationVC = (BWVideoListViewController *)[segue destinationViewController];
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        destinationVC.category = selectedCell.textLabel.text;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
