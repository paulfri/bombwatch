//
//  BWImagePulldownView.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWImagePulldownView.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#define kBWImageCoverTintColor [UIColor colorWithWhite:0.0 alpha:0.30]
#define kBWImageCoverBlurRadius 3.0f
#define kBWImageCoverSaturation 0.9f

@interface BWImagePulldownView ()

@property CGRect cachedImageViewSize;
@property (strong, nonatomic) UIImage *image;

@end

@implementation BWImagePulldownView

- (id)initWithTitle:(NSString *)title imageURL:(NSURL *)url
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 180);
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:frame];
        self.titleLabel.text = title;
        self.titleLabel.textColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.cachedImageViewSize = self.imageView.frame;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        __unsafe_unretained typeof(self) _self = self;

        [self.imageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            _self.image = image;
            [_self updateImageBlurWithRadius:kBWImageCoverBlurRadius];
            NSLog(@"asdfafsd");
        }
                                       failure:nil];

        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = -scrollView.contentOffset.y;
    if (y > 0) {
        self.imageView.frame = CGRectMake(0, scrollView.contentOffset.y, self.cachedImageViewSize.size.width+y, self.cachedImageViewSize.size.height+y);
        self.imageView.center = CGPointMake(self.center.x, self.imageView.center.y);
    }

    float blurRadius = 1 - (scrollView.contentOffset.y * -1) / (scrollView.frame.size.height / 3);
    [self updateImageBlurWithRadius:blurRadius];
    
    float textAlpha  = 1 - (scrollView.contentOffset.y * -1) / (scrollView.frame.size.height / 5);
    self.titleLabel.alpha = textAlpha;
}

- (void)updateImageBlurWithRadius:(float)radius {
    UIImage *blurredImage = [self.image applyBlurWithRadius:radius
                                                   tintColor:kBWImageCoverTintColor
                                       saturationDeltaFactor:kBWImageCoverSaturation
                                                   maskImage:nil];
    
    [self.imageView setImage:blurredImage];
}

@end
