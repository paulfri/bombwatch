//
//  BWVideoListViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoListViewController.h"
#import "BWVideoDetailViewController.h"
#import "GiantBombAPIClient.h"
#import "GBVideo.h"
#import "UIImageView+AFNetworking.h"

@interface BWVideoListViewController ()

@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property NSInteger page;

@end

@implementation BWVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
//    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setTitle:self.category];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadVideos) forControlEvents:UIControlEventValueChanged];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterLongStyle];

    [self loadVideos];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - Giant Bomb API querying methods

- (NSDictionary *)queryParams {
    //2:reviews
    //3:quicklooks
    //4:tang
    //5:endurancerun
    //6:events
    //7:traileres
    //8:features
    //10:subscriber
    NSString *offset = [NSString stringWithFormat:@"%d", (PER_PAGE * (self.page - 1))];
    NSString *perPage = [NSString stringWithFormat:@"%d", PER_PAGE];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[perPage, offset]
                                                                     forKeys:@[@"limit", @"offset"]];

    // TODO: Constantize these at some point
    NSArray *videoCategories = @[@"Latest", @"Quick Looks", @"Features", @"Events",
                             @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                             @"Premium"];
    NSArray *videoEndpoints  = @[@"", @"3", @"8", @"6", @"5", @"4", @"2", @"7", @"10"];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:videoEndpoints
                                                       forKeys:videoCategories];

    if (![self.category isEqualToString:@"Latest"])
        [params addEntriesFromDictionary:@{@"video_type": dict[self.category]}];

    return params;
}

- (void)loadVideos {
    NSDictionary *params = [self queryParams];
    [[GiantBombAPIClient defaultClient] GET:@"videos" parameters:params success:^(NSHTTPURLResponse *response, id responseObject) {

        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
        }

        self.videos = results;
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
    return [self.videos objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    GBVideo *video = [self videoForRowAtIndexPath:indexPath];

    cell.textLabel.text = video.name;
    [cell.imageView setImageWithURL:(NSURL *)video.imageIconURL placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"]];

    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
}
*/

#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffsetY = scrollView.contentOffset.y + [[UIScreen mainScreen] bounds].size.height;
    CGFloat contentHeight = scrollView.contentSize.height;

    if (currentOffsetY > ((contentHeight * 3)/ 4.0)) {
        // if it's >=, we're all caught up and can load the next page
        // if it's < , then there should already be a load in progress
        if(self.videos.count >= (self.page * PER_PAGE)) {
            self.page++;
            [self loadNextPage];
        }
    }
}

- (void)loadNextPage {
    [[GiantBombAPIClient defaultClient] GET:@"videos" parameters:[self queryParams] success:^(NSHTTPURLResponse *response, id responseObject) {
        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
        }
        [self.videos addObjectsFromArray:results];
        [self updateTableView];

    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showVideoDetailSegue"]) {
        BWVideoDetailViewController *controller = [segue destinationViewController];
        controller.video = [self videoForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    } else {
        //
    }
}

#pragma mark - Convenience methods

- (NSAttributedString *)refreshControlTitle {
    return [[NSAttributedString alloc] initWithString:
            [NSString stringWithFormat:@"Last updated %@", [self.dateFormatter stringFromDate:[NSDate date]]]];
}

- (void)updateTableView {
    [self.tableView reloadData];
    self.refreshControl.attributedTitle = [self refreshControlTitle];
    [self.refreshControl endRefreshing];
}

@end
