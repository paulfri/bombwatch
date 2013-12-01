//
//  BWPushNotificationClient.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface BWPushNotificationClient : AFHTTPSessionManager

+ (instancetype)defaultClient;

- (void)registerForPushNotificationsWithToken:(NSString *)token;

@end
