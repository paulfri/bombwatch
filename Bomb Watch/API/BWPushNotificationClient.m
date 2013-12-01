//
//  BWPushNotificationClient.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWPushNotificationClient.h"

NSString *const kBWPushNotificationServerBaseURL = @"http://satonaka.laika.io";

@implementation BWPushNotificationClient

+ (id)defaultClient {
    static BWPushNotificationClient *__defaultClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultClient = [[BWPushNotificationClient alloc] initWithBaseURL:
                           [NSURL URLWithString:kBWPushNotificationServerBaseURL]];
        __defaultClient.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    return __defaultClient;
}

- (void)registerForPushNotificationsWithToken:(NSData *)token
{
    NSDictionary *deviceParams = @{@"token": [token description], @"premium": @"true"};
    
    [[self.class defaultClient] POST:@"devices"
                          parameters:@{@"device": deviceParams}
                             success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSLog(@"Successfully registered for push notifications.");
    }
                             failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"Error registering for push notifications: %@", error);
    }];
}

@end
