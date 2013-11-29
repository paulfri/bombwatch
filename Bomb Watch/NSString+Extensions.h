//
//  NSString+Extensions.h
//  bombwatch
//
//  Created by Paul Friedman on 11/9/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (BOOL)isNilOrEmpty:(NSString *)string;
- (NSString *)stringByTrimmingWhitespaceCharacters;
- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters;

@end
