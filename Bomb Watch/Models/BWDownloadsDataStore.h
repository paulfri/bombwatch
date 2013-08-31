//
//  BWDownloadsDataStore.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    BWDownloadVideoQualityMobile = 0,
    BWDownloadVideoQualityLow = 1,
    BWDownloadVideoQualityHigh = 2,
    BWDownloadVideoQualityHD = 3,
};

@class BWDownload;
@class GBVideo;
@class EVCircularProgressView;

@interface BWDownloadsDataStore : NSObject <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UITableView *tableView;

+ (BWDownloadsDataStore *)defaultStore;

- (void)insertDownload:(BWDownload *)download;

- (BWDownload *)createDownloadWithVideo:(GBVideo *)video;
- (BWDownload *)createDownloadWithVideo:(GBVideo *)video quality:(NSInteger)quality;

- (BOOL)deleteDownloadWithIndexPath:(NSIndexPath *)indexPath;

- (void)cancelRequestForDownload:(BWDownload *)download withProgressView:(EVCircularProgressView *)progressView;
- (void)resumeDownload:(BWDownload *)download;

@end
