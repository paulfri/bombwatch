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
#define kBWImageCoverBlurRadius 2.0f
#define kBWImageCoverSaturation 0.9f

#define kBWMinimumBlurRadiusDelta 0.1f

@interface BWImagePulldownView()
@property CGRect cachedImageViewSize;
@property float cachedBlurRadius;
@property (strong, nonatomic) UIImage *image;
@end

@implementation BWImagePulldownView

- (id)initWithTitle:(NSString *)title imageURL:(NSURL *)url
{
    CGRect screen = [UIScreen mainScreen].bounds;
    CGRect imageFrame = CGRectMake(0, 0, screen.size.width, 180);
    self = [super initWithFrame:imageFrame];

    if (self) {
        CGRect labelFrame = CGRectMake(5, 50, screen.size.width - 5, 180);
        self.titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        self.titleLabel.text = title;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:24.0];
        self.titleLabel.shadowColor = [UIColor grayColor];
        self.titleLabel.shadowOffset = CGSizeMake(0,1);
        self.titleLabel.numberOfLines = 0;
        
        self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.cachedImageViewSize = self.imageView.frame;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        __unsafe_unretained typeof(self) _self = self;

        [self.imageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            _self.image = image;
            [_self updateImageBlurWithRadius:kBWImageCoverBlurRadius];
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
        self.imageView.frame = CGRectMake(0, -y, self.cachedImageViewSize.size.width + y, self.cachedImageViewSize.size.height + y);
        self.imageView.center = CGPointMake(self.center.x, self.imageView.center.y);
    }

    if (scrollView.contentOffset.y < 0) {
        float blurRadius = kBWImageCoverBlurRadius - (scrollView.contentOffset.y * -1) / (scrollView.frame.size.height / 10);
        if(fabsf(self.cachedBlurRadius - blurRadius) > kBWMinimumBlurRadiusDelta) {
            [self updateImageBlurWithRadius:blurRadius];
        }
        
        float textAlpha  = 1 - (scrollView.contentOffset.y * -1) / (scrollView.frame.size.height / 10);
        self.titleLabel.alpha = textAlpha;
    }
}

- (void)updateImageBlurWithRadius:(float)radius
{
    UIImage *blurredImage = [self.image applyBlurWithRadius:radius
                                                  tintColor:kBWImageCoverTintColor
                                      saturationDeltaFactor:kBWImageCoverSaturation
                                                  maskImage:nil];
    
    [self.imageView setImage:blurredImage];
    self.cachedBlurRadius = radius;
    NSLog(@"asdf");
}

@end
