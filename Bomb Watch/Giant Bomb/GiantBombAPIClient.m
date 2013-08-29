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
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"];

    [newParams addEntriesFromDictionary:parameters];
    [newParams setObject:@"json" forKey:@"format"];
    [newParams setObject:token   forKey:@"api_key"];

    NSLog(@"%@", newParams);
    return [super requestWithMethod:method URLString:URLString parameters:newParams];
}

@end
