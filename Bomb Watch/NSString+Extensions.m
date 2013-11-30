//
//  NSString+Extensions.m
//  bombwatch
//
//  Created by Paul Friedman on 11/9/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    if (!string) return YES;

    NSString *trimmedString = [string stringByTrimmingWhitespaceCharacters];
    return ([trimmedString isEqualToString:@""] || ([trimmedString length] == 0));
}

+ (NSString *)stringFromDuration:(NSTimeInterval)duration
{
    long seconds = lroundf(duration); // Modulo (%) operator below needs int or long
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    if (hour > 0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hour, mins, secs];
    }

    return [NSString stringWithFormat:@"%d:%02d", mins, secs];
}

- (NSString *)stringByTrimmingWhitespaceCharacters
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
