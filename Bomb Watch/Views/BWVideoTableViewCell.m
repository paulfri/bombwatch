//
//  BWVideoTableViewCell.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoTableViewCell.h"
#import "BWFavoriteView.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#define kBWFavoritedViewTag 1234
#define kBWVideoCellFont [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define kBWFavoritedAnimationDuration 0.2

@interface BWVideoTableViewCell ()

@property (strong, nonatomic) BWFavoriteView *favoriteView;

@end

@implementation BWVideoTableViewCell

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView
                         style:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initForGesturedTableView:gesturedTableView style:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = kBWVideoCellFont;
        self.textLabel.textColor = [UIColor whiteColor];
        
        self.favoriteView = [[BWFavoriteView alloc] init];
        [self.contentView addSubview:self.favoriteView];
        self.favoriteView.alpha = 0.0;
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_rectangle"]];
        self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)setFavorited:(BOOL)favoritedStatus animated:(BOOL)animated
{
    if (favoritedStatus && animated) {
        [UIView animateWithDuration:kBWFavoritedAnimationDuration animations:^{ self.favoriteView.alpha = 1.0; }];
    } else if (favoritedStatus) {
        self.favoriteView.alpha = 1.0;
    } else if (!favoritedStatus && animated) {
        [UIView animateWithDuration:kBWFavoritedAnimationDuration animations:^{ self.favoriteView.alpha = 0.0; }];
    } else {
        self.favoriteView.alpha = 0.0;
    }
}

- (void)setWatched:(BOOL)watchedStatus animated:(BOOL)animated
{
    if (watchedStatus && animated) {
        self.textLabel.textColor = [UIColor grayColor];
    } else if (watchedStatus) {
        self.textLabel.textColor = [UIColor grayColor];
    } else {
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setBackgroundImageWithURL:(NSURL *)imageURL
{
    __unsafe_unretained typeof(self) _self = self;
    [(UIImageView *)self.backgroundView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                                              placeholderImage:[UIImage imageNamed:@"black_rectangle"]
                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         UIImage *blurredImage = [image applyBlurWithRadius:3.0f
                                                  tintColor:[UIColor colorWithWhite:0.0 alpha:0.30]
                                      saturationDeltaFactor:0.9f
                                                  maskImage:nil];
         ((UIImageView *)_self.backgroundView).image = blurredImage;
     }
                              failure:nil];
}

@end
