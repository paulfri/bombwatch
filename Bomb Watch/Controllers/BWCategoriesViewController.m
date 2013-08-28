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

// this should be constantized somewhere
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

    self.videoCategories = @[@"Latest", @"Quick Look", @"Feature", @"Endurance Run",
                             @"TANG", @"Review", @"Trailer"];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Categories";
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"CategoryCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // TODO: do i have to use a custom cell for this? the default one is probably fine
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = [self.videoCategories objectAtIndex:[indexPath row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

// this section intentionally left blank

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"videoListSegue"]) {
        BWVideoListViewController *destinationVC = (BWVideoListViewController *)[segue destinationViewController];
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        // view with tag 100 should be the label for the selected cell
        // this won't map 1:1 with the api category name, so this will get more complicated
        // or that logic can also go in the video list view controller -- yeah that sounds good
        UILabel *selectedLabel = (UILabel *)[selectedCell viewWithTag:100];
        destinationVC.category = selectedLabel.text;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
