//
//  GiantBombAPIClient.h
//  Gameloggr
//
//  Created by Paul Friedman on 8/25/13.
//  Copyright (c) 2013 Paul Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

#define kBWAPIBaseURLString @"http://www.giantbomb.com/api"
#define kBWDefaultAPIKey    @"e5ab8850b03bcec7ce6590ca705c9a26395dddf1"

@interface GiantBombAPIClient : AFHTTPSessionManager

+ (id)defaultClient;

@end
