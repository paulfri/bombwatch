//
//  BWGenericTableViewCell.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/1/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWGenericTableViewCell.h"

@implementation BWGenericTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor darkGrayColor];
}

@end
