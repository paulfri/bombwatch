//
//  BWDownload.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface BWDownload : NSManagedObject

@property (strong, nonatomic) NSData *video;
@property (strong, nonatomic) NSNumber *videoID;

// metadata about the download
@property (strong, nonatomic) NSDate *started;
@property (strong, nonatomic) NSDate *complete;
@property (strong, nonatomic) NSDate *paused;
@property (strong, nonatomic) NSNumber *progress;

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *localPath;
@property (strong, nonatomic) NSNumber *quality;

@end
