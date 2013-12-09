//
//  BWGenericTableViewCell.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/1/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWGenericTableViewCell.h"

@implementation BWGenericTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor darkGrayColor];
}

@end
