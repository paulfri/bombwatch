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

    NSString *filter;
    NSString *query = searchString;
    
    // set filter and hackish query appends
    if ([[BWVideo categories] containsObject:category]) {
        filter = [NSString stringWithFormat:@"video_type:%@", [BWVideo categoryIDForCategory:category]];
    } else if ([[BWVideo enduranceRunCategories] containsObject:category]) {
        filter = @"video_type:5"; // endurance runs
        params[@"sort"] = @"publish_date";
        query = category;
    } else {
        filter = @"video_type:3|8|6|5|4|2|10"; // latest videos
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

@end
