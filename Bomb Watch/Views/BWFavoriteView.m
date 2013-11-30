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
        UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star-gold-filled"]];
        self.frame = self.superview.frame;

        CGSize star = starView.image.size;
        CGSize screen = [UIScreen mainScreen].bounds.size;
        
        starView.frame = CGRectMake(screen.width - star.width - 3,
                                    (65.0 / 2) - star.height / 2,
                                    star.width,
                                    star.height);
        
        [self addSubview:starView];
    }

    return self;
}

@end
