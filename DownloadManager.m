//
//  DownloadManager.m
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-03.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager()

- (void)continueToNextDownload;

@property (nonatomic, strong) NSMutableArray *downloadKeys;
@property (nonatomic, strong, readwrite) NSMutableDictionary *downloadQueue;
@property (nonatomic, strong, readwrite) NSMutableDictionary *completedDownloads;
@property (nonatomic, strong, readwrite) NSDate              *completedDownloadsResetDate;
@property (nonatomic, strong, readwrite) Download             *currentDownload;

@end

@implementation DownloadManager
@synthesize downloadQueue, completedDownloads, completedDownloadsResetDate, downloadKeys, currentDownload;

#pragma mark - Initialization

static DownloadManager *sharedData;
+ (DownloadManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedData) sharedData = [[DownloadManager alloc] init];
    });
    return sharedData;
}

- (id)init {
    self = [super init];
    if (self) {
        self.downloadQueue = [NSMutableDictionary dictionary];
        self.completedDownloadsResetDate = [NSDate date];
        self.completedDownloads = [NSMutableDictionary dictionary];
        self.downloadKeys = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 
#pragma mark - Download management

- (void)addDownload:(Download *)download withCompletion:(CompletionBlock)completion 
{
    Download*completedDownload = [self.completedDownloads objectForKey:download.url];
    if (completedDownload) {
        completion(completedDownload, completedDownload.downloadData);
    }
    else {
        Download *savedDownload = [self.downloadQueue objectForKey:download.url.absoluteString];
        if (!savedDownload) {
                        
            [self.downloadQueue setObject:download 
                                         forKey:download.url.absoluteString];
            [self.downloadKeys addObject:download.url.absoluteString];
            savedDownload = download;
            
            //Continue To Next Download on Completion
            [savedDownload addCompletionBlock:^(Download *download, NSData*data) {
                [self.completedDownloads setObject:download forKey:download.url];
                [self.downloadQueue removeObjectForKey:download.url];
                [self.downloadKeys removeObject:download.url.absoluteString];
                [self continueToNextDownload]; 
            }];
            [savedDownload addFailBlock:^(Download *download, NSError*error) {
                [self.completedDownloads setObject:download forKey:download.url];
                [self.downloadQueue removeObjectForKey:download.url];
                [self.downloadKeys removeObject:download.url];
                [self continueToNextDownload]; 
            }];
            if (self.downloadQueue.count == 1) {
                [self continueToNextDownload];
            }
        }
        
        
        
        [savedDownload addCompletionBlock:completion];
    }
}

- (void)addImportantDownload:(Download *)download withCompletion:(CompletionBlock)completion;
{    
    Download*completedDownload = [self.completedDownloads objectForKey:download.url];
    if (completedDownload) {
        completion(completedDownload, completedDownload.downloadData);
    }
    else {
        Download *savedDownload = [self.downloadQueue objectForKey:download.url.absoluteString];
        if (!savedDownload) {
            
            NSString *newKey = download.url.absoluteString;
            [self.currentDownload pause];
            NSLog(@"Adding Important Download with URL:%@",download.url.absoluteString);
            
            [self.downloadQueue setObject:download 
                                   forKey:newKey];
            [self.downloadKeys insertObject:newKey atIndex:0];
            savedDownload = download;
            
            //Continue To Next Download on Completion
            [savedDownload addCompletionBlock:^(Download *download, NSData*data) {
                [self.completedDownloads setObject:download forKey:newKey];
                [self.downloadQueue removeObjectForKey:newKey];
                [self.downloadKeys removeObject:newKey];
                [self continueToNextDownload]; 
            }];
            [savedDownload addFailBlock:^(Download *download, NSError*error) {
                [self.completedDownloads setObject:download forKey:newKey];
                [self.downloadQueue removeObjectForKey:newKey];
                [self.downloadKeys removeObject:newKey];
                [self continueToNextDownload]; 
            }];
            [self continueToNextDownload];
      
        }
        
        [savedDownload addCompletionBlock:completion];
    }
}

- (void)continueToNextDownload
{
    Download *downloadToDownload;
    if (self.downloadKeys.count > 0) downloadToDownload = [self.downloadQueue objectForKey:[self.downloadKeys objectAtIndex:0]];
    if (!downloadToDownload) {
        NSLog(@"All Downloads are Done!");
        currentDownload = nil;
        
        //Hide spinner
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }
    else {
        currentDownload = downloadToDownload;
        [downloadToDownload start];
        NSLog(@"Beginning to actually Download URL:%@",downloadToDownload.url.absoluteString);
        
        //Show spinner
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)pause
{
    [self.currentDownload pause];
}
- (void)resume
{
    [self.currentDownload start];
}





@end
