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
#import "SVProgressHUD.h"

@interface BWVideoListViewController ()

@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property NSInteger page;

@end

@implementation BWVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:self.category];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlActivated) forControlEvents:UIControlEventValueChanged];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterLongStyle];

    self.page = 1;
    [SVProgressHUD show];
    [self loadNextPage];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Giant Bomb API querying methods

- (NSDictionary *)queryParams {
    NSString *offset = [NSString stringWithFormat:@"%d", (PER_PAGE * (self.page - 1))];
    NSString *perPage = [NSString stringWithFormat:@"%d", PER_PAGE];

    // TODO: Constantize these at some point
    NSArray *videoCategories = @[@"Latest", @"Quick Looks", @"Features", @"Events",
                             @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                             @"Premium"];
    NSArray *videoEndpoints  = @[@"", @"3", @"8", @"6", @"5", @"4", @"2", @"7", @"10"];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:videoEndpoints
                                                       forKeys:videoCategories];

    NSString *filterValue;

    if (![self.category isEqualToString:@"Latest"]) {
        filterValue = [NSString stringWithFormat:@"video_type:%@", dict[self.category]];
    } else {
        filterValue = @"video_type:3|8|6|5|4|2";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTrailersInLatest"]) {
            filterValue = [filterValue stringByAppendingString:@"|7"];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showPremiumInLatest"]) {
            filterValue = [filterValue stringByAppendingString:@"|10"];
        }
    }

    return @{@"limit": perPage, @"offset": offset, @"filter": filterValue};
}

- (void)refreshControlActivated {
    self.page = 1;
    [self loadNextPage];
}


- (GBVideo *)videoForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.videos objectAtIndex:indexPath.row];
}

- (void)loadNextPage {
    __block NSDictionary *params = [self queryParams];
    
    [[GiantBombAPIClient defaultClient] GET:@"videos" parameters:params success:^(NSHTTPURLResponse *response, id responseObject) {

        // TODO: handle error codes
//        100:Invalid API Key
//        101:Object Not Found
//        104:Filter Error
//        105:Subscriber only video is for subscribers only

        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
        }
        NSLog(@"%@", responseObject);
        
        if([params[@"offset"] isEqualToString:@"0"])
            self.videos = results;
        else
            [self.videos addObjectsFromArray:results];

        [SVProgressHUD dismiss];
        [self updateTableView];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
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
