//
//  GiantBombAPIClient.m
//  Gameloggr
//
//  Created by Paul Friedman on 8/25/13.
//  Copyright (c) 2013 Paul Friedman. All rights reserved.
//

#import "GiantBombAPIClient.h"

@implementation GiantBombAPIClient

+ (id)defaultClient {
    static GiantBombAPIClient *__defaultClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultClient = [[GiantBombAPIClient alloc] initWithBaseURL:
                           [NSURL URLWithString:kBWAPIBaseURLString]];
    });
    
    return __defaultClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    
    NSURL *url = request.URL;
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"];

    NSString *queryString = [NSString stringWithFormat:@"format=json&api_key=%@", apiKey];
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [url absoluteString],
                           [url query] ? @"&" : @"?", queryString];
    
    return [super dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]] completionHandler:completionHandler];
}

@end
