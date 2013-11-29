//
//  NSString+Extensions.m
//  bombwatch
//
//  Created by Paul Friedman on 11/9/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (BOOL)isNilOrEmpty:(NSString *)string {
    if (!string) return YES;

    NSString *trimmedString = [string stringByTrimmingWhitespaceCharacters];
    return ([trimmedString isEqualToString:@""] || ([trimmedString length] == 0));
}

- (NSString *)stringByTrimmingWhitespaceCharacters {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
