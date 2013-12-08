//
//  BWNameFormatter.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWNameFormatter.h"

@implementation BWNameFormatter

+ (NSString *)realNameForUser:(NSString *)user
{
    static NSDictionary *users;

    if (users == nil) {
        users = @{@"jeff": @"Jeff Gerstmann",
                  @"ryan": @"Ryan Davis",
                  @"brad": @"Brad Shoemaker",
                  @"vinny": @"Vinny Caravella",
                  @"patrickklepek": @"Patrick Klepek",
                  @"drewbert": @"Drew Scanlon",
                  @"alex": @"Alex Navarro",
                  @"snide": @"Dave Snider",
                  @"mattbodega": @"Matthew Kessler",
                  @"marino": @"Marino",
                  @"rorie": @"Matt Rorie",
                  @"abauman": @"Andy Bauman",
                  @"danielcomfort": @"Daniel Comfort"};
    }

    if (users[user]) {
        return users[user];
    }

    return user;
}

+ (NSString *)twitterHandleForUser:(NSString *)user
{
    static NSDictionary *users;

    if (users == nil) {
        users = @{@"jeff": @"jeffgerstmann",
                  @"ryan": @"taswell",
                  @"brad": @"bradshoemaker",
                  @"vinny": @"VinnyCaravella",
                  @"patrickklepek": @"patrickklepek",
                  @"drewbert": @"drewscanlon",
                  @"alex": @"alex_navarro",
                  @"snide": @"enemykite",
                  @"mattbodega": @"MattBodega",
                  @"rorie": @"frailgesture",
                  @"abauman": @"andybauman"};
    }

    if (users[user]) {
        return users[user];
    }

    return user;
}

@end
