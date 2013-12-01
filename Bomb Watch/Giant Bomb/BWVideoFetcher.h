//
//  BWVideoFetcher.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBWVideosPerPage 50

@interface BWVideoFetcher : NSObject

+ (id)defaultFetcher;

- (void)fetchVideosForCategory:(NSString *)category
                  searchString:(NSString *)searchString
                          page:(NSInteger)page
                       success:(void (^)(NSArray *))success
                       failure:(void (^)(NSError *))failure;

@end
