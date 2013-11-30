//
//  BWFavoriteView.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWFavoriteView.h"

@implementation BWFavoriteView

- (id)initWithTag:(NSInteger)tag
{
    self = [super init];

    if (self) {
        self.tag = tag;
        
        UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ToolbarFavorite"]];
        starView.backgroundColor = [UIColor yellowColor];

        CGSize star = starView.image.size;
        CGSize screen = [UIScreen mainScreen].bounds.size;
        
        starView.frame = CGRectMake(screen.width - star.width - 3, 3, star.width, star.height);
        [self addSubview:starView];
    }

    return self;
}

@end
