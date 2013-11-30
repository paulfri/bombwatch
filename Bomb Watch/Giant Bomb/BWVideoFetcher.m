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
                           page:(NSInteger)page
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure
{
    [[GiantBombAPIClient defaultClient] GET:@"videos"
                                 parameters:[self queryParamsForCategory:category page:page]
                                    success:^(NSURLSessionDataTask *task, id responseObject)
     {
         NSMutableArray *results = [NSMutableArray array];

         for (id gameDictionary in [responseObject valueForKey:@"results"]) {
             BWVideo *video = [MTLJSONAdapter modelOfClass:BWVideo.class
                                        fromJSONDictionary:(NSDictionary *)gameDictionary
                                                     error:NULL];
             [results addObject:video];
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

- (NSDictionary *)queryParamsForCategory:(NSString *)category page:(NSInteger)page
{
    NSString *offset = [NSString stringWithFormat:@"%d", (kBWVideosPerPage * (page - 1))];
    NSString *perPage = [NSString stringWithFormat:@"%d", kBWVideosPerPage];
    
    // TODO: Constantize these at some point
    NSArray *videoCategories = @[@"Quick Looks", @"Features", @"Events",
                                 @"Endurance Run", @"TANG", @"Reviews", @"Trailers",
                                 @"Subscriber"];
    NSArray *videoEndpoints  = @[@"3", @"8", @"6", @"5", @"4", @"2", @"7", @"10"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:videoEndpoints
                                                       forKeys:videoCategories];
    
    NSString *filter;
    NSString *query = @"";
    
    if ([videoCategories containsObject:category]) {
        // standard categories
        filter = [NSString stringWithFormat:@"video_type:%@", dict[category]];
    } else if ([self categoryIsEnduranceRun:category]) {
        // endurance runs
        filter = @"video_type:5";
        query = category;
    } else {
        // latest videos
        filter = @"video_type:3|8|6|5|4|2|10";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTrailersInLatest"]) {
            filter = [filter stringByAppendingString:@"|7"];
        }
    }
    
    if ([self categoryIsEnduranceRun:category]) {
        return @{@"limit": perPage, @"offset": offset, @"filter": filter, @"resources": @"video", @"sort": @"publish_date"};
    }
    
    return @{@"limit": perPage, @"offset": offset, @"filter": filter};
}

- (BOOL)categoryIsEnduranceRun:(NSString *)category {
    return [@[@"Persona 4", @"Deadly Premonition", @"The Matrix Online", @"Chrono Trigger"] containsObject:category];
}

@end
