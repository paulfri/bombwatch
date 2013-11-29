//
//  BWSeparatorView.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/5/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWSeparatorView.h"

@implementation BWSeparatorView

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    CGFloat alpha = CGColorGetAlpha(backgroundColor.CGColor);
    if (alpha != 0) {
        [super setBackgroundColor:backgroundColor];
    } else {
        [super setBackgroundColor:self.selectColor];
    }
}

@end
