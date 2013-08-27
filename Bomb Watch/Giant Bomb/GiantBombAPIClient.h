//
//  GiantBombAPIClient.h
//  Gameloggr
//
//  Created by Paul Friedman on 8/25/13.
//  Copyright (c) 2013 Paul Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface GiantBombAPIClient : AFHTTPClient

+ (id)defaultClient;

@end
