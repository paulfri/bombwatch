//
//  BWDownloadsDataStore.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/30/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BWDownloadsDataStore.h"
#import "BWDownload.h"
#import "GBVideo.h"
#import "GiantBombAPIClient.h"
#import "AFDownloadRequestOperation.h"
#import "EVCircularProgressView.h"

@implementation BWDownloadsDataStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize tableView = _tableView;

+ (BWDownloadsDataStore *)defaultStore {
    static BWDownloadsDataStore *defaultStore = nil;
    if(!defaultStore)
        defaultStore = [[super allocWithZone:nil] init];

    return defaultStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultStore];
}

- (id)init {
    self = [super init];
    return self;
}

#pragma mark - Data Store Helpers

-(BWDownload *)createDownloadWithVideo:(GBVideo *)video {
    return [self createDownloadWithVideo:video quality:0];
}

-(BWDownload *)createDownloadWithVideo:(GBVideo *)video quality:(NSInteger)quality {
    BWDownload *download = [NSEntityDescription insertNewObjectForEntityForName:@"Download"
                                                        inManagedObjectContext:[self managedObjectContext]];
    download.video = video;
    download.videoID = video.videoID;
    download.started = [NSDate date];
    download.quality = [NSNumber numberWithInt:quality];

    switch (quality) {
        case 0: // mobile
            download.path = [video.videoLowURL absoluteString];
            // TODO: grep the low path and replace with '.ipod'
            break;
        case 1: // low
            download.path = [video.videoLowURL absoluteString];
            break;
        case 2: // high
            download.path = [video.videoHighURL absoluteString];
            break;
        case 3: // hd
            download.path = [video.videoHDURL absoluteString];
            break;
        default:
            break;
    }
//    download.path = [video.videoLowURL absoluteString];
    //    download.localPath = [NSHomeDirectory() stringByAppendingPathComponent:relativePath];
    //    download.localPath = [NSString stringWithFormat:@"Documents/%@-%d.mp4", download.videoID, [download.quality intValue]];

    NSString *filename = [NSString stringWithFormat:@"%@-%d.mp4", download.videoID, [download.quality intValue]];
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    download.localPath = [docs stringByAppendingPathComponent:filename];
//    download.localPath = [[[NSBundle mainBundle] URLForResource:relativePath withExtension:@"mp4" subdirectory:@"Documents"] relativePath];

    [self insertDownload:download];
    [self resumeDownload:download];
    return download;
}

-(void)insertDownload:(BWDownload *)download {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context insertObject:download];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(BOOL)deleteDownloadWithIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [[BWDownloadsDataStore defaultStore] managedObjectContext];
    BWDownload *download = [[[BWDownloadsDataStore defaultStore] fetchedResultsController] objectAtIndexPath:indexPath];
    [[NSFileManager defaultManager] removeItemAtPath:download.localPath error:nil];
    [self cancelRequestForDownload:download];
    [context deleteObject:download];

    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return YES;
    
}

#pragma mark - Downloading helpers

- (void)cancelRequestForDownload:(BWDownload *)download {
    [self cancelRequestForDownload:download withProgressView:nil];
}

- (void)cancelRequestForDownload:(BWDownload *)download withProgressView:(EVCircularProgressView *)progressView {
    for (NSOperation *op in [[[GiantBombAPIClient defaultClient] operationQueue] operations]) {
        if ([op isKindOfClass:[AFDownloadRequestOperation class]]) {
            AFDownloadRequestOperation *dl = (AFDownloadRequestOperation *)op;
            if ([[dl.request.URL absoluteString] isEqualToString:download.path]) {
                [op cancel];
                download.complete = nil;
                if (progressView != nil) {
                    download.paused = [NSDate date];
                    download.progress = [NSNumber numberWithFloat:progressView.progress];
                }
            }
        }
    }
}

- (void)resumeDownload:(BWDownload *)download {
    download.paused = nil;
    download.complete = nil;
    download.progress = nil;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:download.path]];

    __block BWDownload *blockDownload = download;
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                                                     targetPath:download.localPath
                                                                                   shouldResume:YES];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        download.complete = [NSDate date];
        download.paused = nil;
        download.progress = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoDownloadCompleteNotification"
                                                            object:self
                                                          userInfo:@{@"download": blockDownload,
                                                                     @"path": blockDownload.path}];

        // all of this seems to be unncessary and maybe not even work.
        // saving on the main thread for now. who knows what fun bugs will happen

#warning maybe try this (2nd answer) http://stackoverflow.com/questions/2138252/core-data-multi-thread-application
//        NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        [backgroundContext setParentContext:self.managedObjectContext];
        //Use backgroundContext to insert/update...
        //Then just save the context, it will automatically sync to your primary context
//        NSLog(@"%@", backgroundContext.parentContext);
//        NSError *error = nil;
//        if (![backgroundContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
        [self.managedObjectContext save:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %ld", (long)[error code]);
        if (!((long)[error code]) == 999) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoDownloadErrorNotification"
                                                                object:self
                                                              userInfo:@{@"download": blockDownload,
                                                                         @"path": blockDownload.path}];            
        }
    }];
    
    // can i set this later???
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        float progress = ((float)totalBytesReadForFile) / totalBytesExpectedToReadForFile;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoProgressUpdateNotification"
                                                            object:self
                                                          userInfo:@{@"download": blockDownload,
                                                                     @"progress": [NSNumber numberWithFloat:progress],
                                                                     @"path": blockDownload.path}];
    }];
    
    [[GiantBombAPIClient defaultClient] enqueueHTTPRequestOperation:operation];
}



#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - NSFetchedResultController Methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"started" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
