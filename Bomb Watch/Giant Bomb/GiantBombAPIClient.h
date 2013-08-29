//
//  GiantBombAPIClient.h
//  Gameloggr
//
//  Created by Paul Friedman on 8/25/13.
//  Copyright (c) 2013 Paul Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define GiantBombAPIBaseURLString @"http://www.giantbomb.com/api"
#define GiantBombDefaultAPIKey  @"e5ab8850b03bcec7ce6590ca705c9a26395dddf1"

@interface GiantBombAPIClient : AFHTTPClient

+ (id)defaultClient;

@end
