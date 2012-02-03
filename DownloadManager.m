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
@end

@implementation DownloadManager
@synthesize downloadQueue, completedDownloads, completedDownloadsResetDate, downloadKeys;

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
        completion(completedDownload.url.absoluteString,completedDownload.activeDownload,nil);
    }
    else {
        Download *savedDownload = [self.downloadQueue objectForKey:download.url.absoluteString];
        if (!savedDownload) {
            
            NSLog(@"Adding Download with URL:%@",download.url.absoluteString);
            
            [self.downloadQueue setObject:download 
                                         forKey:download.url.absoluteString];
            [self.downloadKeys addObject:download.url.absoluteString];
            savedDownload = download;
            
            //Continue To Next Download on Completion
            [savedDownload addCompletionBlock:^(NSString *url, NSData *data, NSDate *completionDate) {
                Download*download = [self.downloadQueue objectForKey:url];
                [self.completedDownloads setObject:download forKey:url];
                [self.downloadQueue removeObjectForKey:url];
                [self.downloadKeys removeObject:url];
                [self continueToNextDownload]; 
            }];
            [savedDownload addFailBlock:^(NSString *url, NSError *error, NSDate *failDate) {
                Download*download = [self.downloadQueue objectForKey:url];
                [self.completedDownloads setObject:download forKey:url];
                [self.downloadQueue removeObjectForKey:url];
                [self.downloadKeys removeObject:url];
                [self continueToNextDownload]; 
            }];
            if (self.downloadQueue.count == 1) {
                [self continueToNextDownload];
            }
        }
        
        
        
        [savedDownload addCompletionBlock:completion];
    }
}

- (void)continueToNextDownload
{
    Download *downloadToDownload = [self.downloadQueue objectForKey:[self.downloadKeys lastObject]];
    if (!downloadToDownload) {
        NSLog(@"All Downloads are Done!");
        
        //Hide spinner
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }
    else {
        [downloadToDownload start];
        NSLog(@"Beginning to actually Download URL:%@",downloadToDownload.url.absoluteString);
        
        //Show spinner
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}




@end
