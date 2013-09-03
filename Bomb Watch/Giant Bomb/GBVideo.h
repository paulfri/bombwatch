//
//  GBVideo.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GiantBombVideoEmptyURL @"http://v.giantbomb.com/null"

@interface GBVideo : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *videoID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *apiDetailURL;
@property (strong, nonatomic) NSURL *siteDetailURL;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) NSURL *videoMobileURL;
@property (strong, nonatomic) NSURL *videoLowURL;
@property (strong, nonatomic) NSURL *videoHighURL;
@property (strong, nonatomic) NSURL *videoHDURL;
@property (strong, nonatomic) NSURL *imageIconURL; // square aspect ratio
@property (strong, nonatomic) NSURL *imageMediumURL;
@property (strong, nonatomic) NSNumber *lengthInSeconds;
@property (strong, nonatomic) NSDate *publishDate;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *videoType;

// missing: video_type
// missing: youtube_id

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isWatched;
- (void)setWatched;
- (void)setUnwatched;

- (BOOL)isPremium;

@end

//{
//    "id": 7880,
//    "name": "Your Friends Are the Monsters In Crawl",
//    "api_detail_url": "http://www.giantbomb.com/api/video/2300-7880/",
//    "site_detail_url": "http://www.giantbomb.com/videos/your-friends-are-the-monsters-in-crawl/2300-7880/",
//    "deck": "No, seriously. You're the hero, they're the bad guys, and you eventually switch places.",
//    "url": "tr_crawl_082713.mp4",
//    "low_url": "http://v.giantbomb.com/2013/08/27/tr_crawl_082713_800.mp4",
//    "high_url": "http://v.giantbomb.com/2013/08/27/tr_crawl_082713_1800.mp4",
//    "hd_url": "http://www.giantbomb.com/api/protected_video/2300-7880/?download=1",
//    "length_seconds": 70,
//    "publish_date": "2013-08-27 07:53:00",
//    "image": {
//        "icon_url": "http://static.giantbomb.com/uploads/square_avatar/9/93998/2535805-crawl.png",
//        "medium_url": "http://static.giantbomb.com/uploads/scale_medium/9/93998/2535805-crawl.png",
//        "screen_url": "http://static.giantbomb.com/uploads/screen_medium/9/93998/2535805-crawl.png",
//        "small_url": "http://static.giantbomb.com/uploads/scale_small/9/93998/2535805-crawl.png",
//        "super_url": "http://static.giantbomb.com/uploads/scale_large/9/93998/2535805-crawl.png",
//        "thumb_url": "http://static.giantbomb.com/uploads/scale_avatar/9/93998/2535805-crawl.png",
//        "tiny_url": "http://static.giantbomb.com/uploads/square_mini/9/93998/2535805-crawl.png",
//    },
//    "user": patrickklepek,
//    "video_type": Trailers,
//    "youtube_id": "<null>",
//}