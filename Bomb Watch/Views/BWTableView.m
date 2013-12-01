//
//  BWTableView.m
//  Bomb Watch
//
//  Created by Paul Friedman on 12/1/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWTableView.h"

@implementation BWTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:34.0/255 green:34.0/255 blue:34.0/255 alpha:1.0];
    }
    return self;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:34.0/255 green:34.0/255 blue:34.0/255 alpha:1.0];
    cell.textLabel.textColor = [UIColor whiteColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
