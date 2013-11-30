//
//  BWFavoriteView.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWFavoriteView.h"

@implementation BWFavoriteView

- (id)init
{
    self = [super init];

    if (self) {
        UIView *favoriteBar = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 3, 0, 3, 65)];
        favoriteBar.backgroundColor = [UIColor colorWithRed:1 green:252.0/255 blue:25.0/255 alpha:1];
        [self addSubview:favoriteBar];

        self.tag = 1234;
    }

    return self;
}

@end
