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

@interface BWLatestViewController ()

@property (strong, nonatomic) NSArray *latestVideos;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation BWLatestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
//    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setTitle:@"Latest"];
    [self loadLatestVideos];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadLatestVideos) forControlEvents:UIControlEventValueChanged];
}

- (void)loadLatestVideos {
//        NSDictionary *params = @{@"query": query, @"resources":@"game"};
    [[GiantBombAPIClient defaultClient] GET:@"videos" parameters:nil success:^(NSHTTPURLResponse *response, id responseObject) {

        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
            NSLog(@"%@", video.name);
        }

        self.latestVideos = results;
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    GBVideo *video = [self videoForRowAtIndexPath:indexPath];

    cell.textLabel.text = video.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
}

@end
