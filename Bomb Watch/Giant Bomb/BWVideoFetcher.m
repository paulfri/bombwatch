//
//  BWVideoFetcher.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoFetcher.h"
#import "GiantBombAPIClient.h"
#import "BWVideo.h"
#import <Mantle/Mantle.h>
#import "BWVideoDataStore.h"

@implementation BWVideoFetcher

+ (instancetype)defaultFetcher
{
    static BWVideoFetcher *__defaultFetcher;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        __defaultFetcher = [[BWVideoFetcher alloc] init];
    });
    
    return __defaultFetcher;
}

- (void)fetchVideosForCategory:(NSString *)category
                  searchString:(NSString *)searchString
                          page:(NSInteger)page
                       success:(void (^)(NSArray *))success
                       failure:(void (^)(NSError *))failure
{
    [[GiantBombAPIClient defaultClient] GET:@"videos"
                                 parameters:[self queryParamsForCategory:category searchString:searchString page:page]
                                    success:^(NSURLSessionDataTask *task, id responseObject)
     {
         NSMutableArray *results = [NSMutableArray array];

         for (id gameDictionary in [responseObject valueForKey:@"results"]) {
             BWVideo *video = [MTLJSONAdapter modelOfClass:BWVideo.class
                                        fromJSONDictionary:(NSDictionary *)gameDictionary
                                                     error:NULL];
             [results addObject:video];
         }

         if (results.count > 0 && page == 1) {
              [[BWVideoDataStore defaultStore] setCachedVideos:results forCategory:category];
         }

         if (success) {
             success(results);
         }
     }
                                    failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"%@", error);
         
         if (failure) {
             failure(error);
         }
     }];

}

- (NSDictionary *)queryParamsForCategory:(NSString *)category searchString:(NSString *)searchString page:(NSInteger)page
{
    NSMutableDictionary *params = [@{@"offset": [NSString stringWithFormat:@"%d", (kBWVideosPerPage * (page - 1))],
                                     @"limit": [NSString stringWithFormat:@"%d", kBWVideosPerPage]} mutableCopy];

    // TODO: Constantize these at some point
    NSArray *videoCategories = @[@"Quick Looks", @"Features", @"Events",
                                 @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                                 @"Subscriber"];
    NSArray *videoEndpoints  = @[@"3", @"8", @"6", @"5", @"4", @"2", @"7", @"10"];
    
    NSDictionary *categoryMap = [[NSDictionary alloc] initWithObjects:videoEndpoints
                                                              forKeys:videoCategories];
    
    NSString *filter;
    NSString *query = searchString;
    
    // set filter and hackish query appends
    if ([videoCategories containsObject:category]) {
        filter = [NSString stringWithFormat:@"video_type:%@", categoryMap[category]];
    } else if ([self categoryIsEnduranceRun:category]) {
        // endurance runs
        filter = @"video_type:5";
        params[@"sort"] = @"publish_date";
        query = category;
    } else {
        // latest videos
        filter = @"video_type:3|8|6|5|4|2|10";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTrailersInLatest"]) {
            filter = [filter stringByAppendingString:@"|7"];
        }
    }

    if (query) {
        filter = [filter stringByAppendingString:[NSString stringWithFormat:@",name:%@",query]];
    }

    params[@"filter"] = filter;
    NSLog(@"%@", params);
    return params;
}

- (BOOL)categoryIsEnduranceRun:(NSString *)category
{
    return [@[@"Persona 4", @"Deadly Premonition", @"The Matrix Online", @"Chrono Trigger"] containsObject:category];
}

@end
