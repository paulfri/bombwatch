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
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSNumber *videoID;

@end
