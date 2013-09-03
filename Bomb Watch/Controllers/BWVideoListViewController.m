//
//  BWVideoListViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
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
@property BOOL reachedEnd;

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

    self.reachedEnd = NO;
    self.page = 1;
    [SVProgressHUD show];
    [self loadNextPage];

    // TODO find better way to do this
    self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Videos"
                                                                         image:[UIImage imageNamed:@"VideosTabIcon"]
                                                                 selectedImage:[UIImage imageNamed:@"VideosTabIconFull"]];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)isEnduranceRun {
    NSArray *enduranceRuns = @[@"Persona 4", @"Deadly Premonition BR", @"Deadly Premonition VJ",
                               @"The Matrix Online", @"Chrono Trigger"];

    return [enduranceRuns containsObject:self.category];
}

#pragma mark - Giant Bomb API querying methods

- (NSDictionary *)queryParams {
    NSString *offset = [NSString stringWithFormat:@"%d", (PER_PAGE * (self.page - 1))];
    NSString *perPage = [NSString stringWithFormat:@"%d", PER_PAGE];

    // TODO: Constantize these at some point
    NSArray *videoCategories = @[@"Quick Looks", @"Features", @"Events",
                             @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                             @"Subscriber"];
    NSArray *videoEndpoints  = @[@"3", @"8", @"6", @"5", @"4", @"2", @"7", @"10"];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:videoEndpoints
                                                       forKeys:videoCategories];

    NSString *filter;
    NSString *query = @"";

    if ([videoCategories containsObject:self.category]) {
        // standard categories
        filter = [NSString stringWithFormat:@"video_type:%@", dict[self.category]];
    } else if ([self isEnduranceRun]) {
        // endurance runs
        filter = @"video_type:5";
        query = self.category;
    } else {
        // latest videos
        filter = @"video_type:3|8|6|5|4|2|10";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTrailersInLatest"]) {
            filter = [filter stringByAppendingString:@"|7"];
        }
    }

    if ([self isEnduranceRun]) {
        return @{@"limit": perPage, @"offset": offset, @"filter": filter, @"resources": @"video", @"sort": @"publish_date"};
    }

    return @{@"limit": perPage, @"offset": offset, @"filter": filter};
}

- (void)refreshControlActivated {
    self.page = 1;
    self.reachedEnd = NO;
    [self loadNextPage];
}


- (GBVideo *)videoForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.videos objectAtIndex:indexPath.row];
}

- (void)loadNextPage {
    if ([self reachedEnd]) return;

    NSString *endpoint = @"videos";
    __block NSDictionary *params = [self queryParams];

    [[GiantBombAPIClient defaultClient] GET:endpoint parameters:params success:^(NSHTTPURLResponse *response, id responseObject) {

// TODO: handle error codes
//        100:Invalid API Key
//        101:Object Not Found
//        104:Filter Error
//        105:Subscriber only video is for subscribers only
        if ((self.videos.count + [responseObject[@"results"] count]) >= [[responseObject valueForKey:@"number_of_total_results"] integerValue]) {
            self.reachedEnd = YES;
        }

        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
//            if ([self isEnduranceRun]) {
//                if ([video.name rangeOfString:self.category].location != NSNotFound) [results addObject:video];
//            } else
                [results addObject:video];
        }

        if([params[@"offset"] isEqualToString:@"0"])
            self.videos = results;
        else
            [self.videos addObjectsFromArray:results];

// TODO: this might be useful for the endurance run lists
//        NSArray *sortedArray;
//        sortedArray = [self.videos sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//            NSDate *first = [(GBVideo *)a publishDate];
//            NSDate *second = [(GBVideo *)b publishDate];
//            return [first compare:second];
//        }];
//        self.videos = [sortedArray mutableCopy];

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
    static NSString *CellIdentifier = @"VideoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GBVideo *video = [self videoForRowAtIndexPath:indexPath];

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.text = video.name;
    if ([video isWatched])
        titleLabel.textColor = [UIColor grayColor];
    else
        titleLabel.textColor = [UIColor blackColor];

    if ([video isPremium])
        titleLabel.textColor = [UIColor greenColor];
    
    ((UILabel *)[cell viewWithTag:3]).text = video.summary;

    UIImageView *imagePreview = (UIImageView *)[cell viewWithTag:1];
    NSURLRequest *request = [NSURLRequest requestWithURL:video.imageIconURL];
    __block UIImageView *preview = imagePreview;
    
    [imagePreview setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        UIImage *playBtn = [UIImage imageNamed:@"video-play-sm"];

        UIGraphicsBeginImageContextWithOptions(image.size, FALSE, 0.0);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [playBtn drawInRect:CGRectMake(image.size.width/2 - (playBtn.size.width/2), image.size.height/2 - (playBtn.size.height/2), playBtn.size.width, playBtn.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        preview.image = newImage;
    } failure:nil];

    // one-time configuration
    if (cell.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo:)];
        [imagePreview addGestureRecognizer:tapped];

        imagePreview.layer.masksToBounds = YES;
        imagePreview.layer.cornerRadius = 4;
        cell.separatorInset = UIEdgeInsetsMake(0, imagePreview.bounds.size.width + 11, 0, 0);
    }

    return cell;
}

- (void)playVideo:(id)sender {
    UITapGestureRecognizer *senderRec = (UITapGestureRecognizer *)sender;
    UITableViewCell *cell = (UITableViewCell *)senderRec.view.superview.superview.superview;
//    NSLog(@"%@", [senderRec.view.superview.superview.superview class]);
    GBVideo *video = [self videoForRowAtIndexPath:[self.tableView indexPathForCell:cell]];

//    NSLog(@"%@", [self.tableView indexPathForCell:cell]);
//
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] init];
    player.moviePlayer.fullscreen = YES;
    player.moviePlayer.allowsAirPlay = YES;
//
//    // TODO: support default quality and local playback
    NSURL *contentURL = video.videoMobileURL;
    player.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
    player.moviePlayer.contentURL = contentURL;
    [self presentMoviePlayerViewControllerAnimated:player];
    [player.moviePlayer play];
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

#warning Here's how the GB Boxee client implemented the ER list views
//if cat_id == 'latest':
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&sort=-publish_date&format=json')
//elif cat_id == 'search':
//query = mc.ShowDialogKeyboard("Search", "", False).replace(' ', '%20')
//response = mc.Http().Get(API_PATH + '/search/?api_key=' + API_KEY + '&resources=video&query=' + query + '&format=json')
//elif cat_id == '5-CT':
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&video_type=5&offset=240&format=json')
//elif cat_id == '5-DP':
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&video_type=5&offset=161&limit=79&format=json')
//elif cat_id == '5-P4':
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&video_type=5&format=json')
//elif cat_id == '5-MO':
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&video_type=5&offset=105&limit=21&format=json')
//else:
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&video_type=' + cat_id + '&sort=-publish_date&format=json')
//
//video_data = simplejson.loads(response)['results']
//
//if cat_id == '5-P4':
//response = mc.Http().Get(API_PATH + '/videos/?api_key=' + API_KEY + '&video_type=5&offset=100&limit=61&format=json')
//video_data += simplejson.loads(response)['results']
//video_data = [video for video in video_data if not video['name'].startswith('The Matrix Online')]
//elif cat_id == '5-MO':
//video_data = [video for video in video_data if video['name'].startswith('The Matrix Online')]


@end
