//
//  BWDownloadsDataStore.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BWDownload;
@class GBVideo;

@interface BWDownloadsDataStore : NSObject <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UITableView *tableView;

+ (BWDownloadsDataStore *)defaultStore;

- (void)insertDownload:(BWDownload *)download;
- (BWDownload *)createDownloadWithVideo:(GBVideo *)video;
- (BOOL)deleteDownloadWithIndexPath:(NSIndexPath *)indexPath;

@end
