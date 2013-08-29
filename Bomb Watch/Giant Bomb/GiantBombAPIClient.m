//
//  GiantBombAPIClient.m
//  Gameloggr
//
//  Created by Paul Friedman on 8/25/13.
//  Copyright (c) 2013 Paul Friedman. All rights reserved.
//

#import "GiantBombAPIClient.h"

#define GiantBombAPIBaseURLString @"http://www.giantbomb.com/api"
#define GiantBombAPIToken         @"064d830691a4b7323a7424bffa5ce1c8d7552962"

@implementation GiantBombAPIClient

+ (id)defaultClient {
    static GiantBombAPIClient *__defaultClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultClient = [[GiantBombAPIClient alloc] initWithBaseURL:
                            [NSURL URLWithString:GiantBombAPIBaseURLString]];
    });
    
    return __defaultClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONSerializer serializer];
    }
    
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    [newParams addEntriesFromDictionary:parameters];
    [newParams setObject:@"json" forKey:@"format"];
    [newParams setObject:GiantBombAPIToken forKey:@"api_key"];

    return [super requestWithMethod:method URLString:URLString parameters:newParams];
}

@end
