//
//  BWNameFormatter.h
//  Bomb Watch
//
//  Created by Paul Friedman on 12/7/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWNameFormatter : NSObject

+ (NSString *)realNameForUser:(NSString *)user;
+ (NSString *)twitterHandleForUser:(NSString *)user;

@end
