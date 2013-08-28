//
//  BWFirstViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWLatestViewController.h"
#import "GiantBombAPIClient.h"
#import "GBVideo.h"
#import "UIImageView+AFNetworking.h"
#import "BWVideoDetailViewController.h"

@interface BWLatestViewController ()

@property (strong, nonatomic) NSMutableArray *latestVideos;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property NSInteger page;

@end

@implementation BWLatestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
//    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setTitle:@"Latest"];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadLatestVideos) forControlEvents:UIControlEventValueChanged];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterLongStyle];

    [self loadLatestVideos];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)loadLatestVideos {
//    NSDictionary *params = @{@"query": query, @"resources":@"game"};
    [[GiantBombAPIClient defaultClient] GET:@"videos" parameters:nil success:^(NSHTTPURLResponse *response, id responseObject) {

        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
        }

        self.latestVideos = results;
        self.page = 1;
        [self updateTableView];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GBVideo *)videoForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.latestVideos objectAtIndex:indexPath.row];
}

- (void)updateTableView {
    [self.tableView reloadData];
    self.refreshControl.attributedTitle = [self refreshControlTitle];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.latestVideos.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
////    return 70;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    GBVideo *video = [self videoForRowAtIndexPath:indexPath];

    cell.textLabel.text = video.name;
    [cell.imageView setImageWithURL:(NSURL *)video.imageIconURL placeholderImage:[UIImage imageNamed:@"placeholder-square.jpg"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
}

#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffsetY = scrollView.contentOffset.y + [[UIScreen mainScreen] bounds].size.height;
    CGFloat contentHeight = scrollView.contentSize.height;

    if (currentOffsetY > ((contentHeight * 3)/ 4.0)) {
        // if it's equal, we're all caught up and can load the next page
        // if it's less than, then there should already be a load in progress
        NSLog(@"thinking about loading more: %d shown and %d should be shown", self.latestVideos.count, self.page * PER_PAGE);
        if(self.latestVideos.count >= (self.page * PER_PAGE)) {
            self.page = self.page + 1;
            [self loadNextPage];
        }
    }
}

- (void)loadNextPage {
    NSString *offset = [NSString stringWithFormat:@"%d", (PER_PAGE * (self.page - 1))];
    NSDictionary *params = @{@"limit": @"25", @"offset":offset};

    [[GiantBombAPIClient defaultClient] GET:@"videos" parameters:params success:^(NSHTTPURLResponse *response, id responseObject) {
        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
        }
        [self.latestVideos addObjectsFromArray:results];
        [self updateTableView];

    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BWVideoDetailViewController *controller = [segue destinationViewController];
    controller.video = [self videoForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
}

#pragma mark - Convenience methods
- (NSAttributedString *)refreshControlTitle {
    return [[NSAttributedString alloc] initWithString:
            [NSString stringWithFormat:@"Last updated %@", [self.dateFormatter stringFromDate:[NSDate date]]]];
}

@end
