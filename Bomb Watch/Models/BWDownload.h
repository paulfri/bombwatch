//
//  BWDownload.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface BWDownload : NSManagedObject

@property (strong, nonatomic) NSDate *downloadComplete;
@property (strong, nonatomic) NSData *video;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDate *paused;

@end
