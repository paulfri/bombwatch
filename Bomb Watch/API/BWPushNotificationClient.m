//
//  BWPushNotificationClient.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWPushNotificationClient.h"

const NSString *kBWPushNotificationServerBaseURL = @"http://satonaka.laika.io";

@implementation BWPushNotificationClient

+ (id)defaultClient {
    static BWPushNotificationClient *__defaultClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultClient = [[BWPushNotificationClient alloc] initWithBaseURL:
                           [NSURL URLWithString:kBWPushNotificationServerBaseURL]];
    });
    
    return __defaultClient;
}

@end
