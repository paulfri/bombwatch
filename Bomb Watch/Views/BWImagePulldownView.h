//
//  BWImagePulldownView.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWImagePulldownView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;

- (id)initWithTitle:(NSString *)title imageURL:(NSURL *)url;

@end
