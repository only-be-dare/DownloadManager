//
//  Download.m
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-03.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import "Download.h"

@interface Download()
- (void)startDownloading;
@end

@implementation Download {
    BOOL hasBeenStarted;
    float amountDownloaded;
    float expectedSize;
}

+ (id)downloadFromURLString:(NSString *)urlString writeToPath:(NSString *)apath; 
{
    Download *download = [[Download alloc] init];
    download.url = [NSURL URLWithString:urlString];
    download.completionBlocks = [NSMutableArray array];
    download.failBlocks = [NSMutableArray array];
    download.savePath = apath;
    return download;
}
- (id)start
{
    if (hasBeenStarted != TRUE) [self startDownloading];
    else {
        [self resume];
        
        
    }
    return self;    
}

- (void)startDownloading 
{
    hasBeenStarted = TRUE;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *localSavePath = self.savePath; 
    
    if( [manager fileExistsAtPath:localSavePath] )
    {
        NSError *error = [[NSError alloc] init];
        [manager removeItemAtPath:localSavePath error:&error];
    }
    [manager createFileAtPath:localSavePath contents:[NSData data] attributes:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    
    
    if (self.downloadData.length > 0) {
        
        NSLog(@"Should resume url %@",self.url);
        // Define the bytes we wish to download.
        NSString *range = [NSString stringWithFormat:@"bytes=%i-", self.downloadData.length];
        [request setValue:range forHTTPHeaderField:@"Range"];
    }
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = conn;  
}

- (id)resume
{
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    
    if (self.downloadData.length > 0) {
        
        NSLog(@"Should resume url %@",self.url);
        // Define the bytes we wish to download.
        NSString *range = [NSString stringWithFormat:@"bytes=%i-", self.downloadData.length];
        [request setValue:range forHTTPHeaderField:@"Range"];
    }
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = conn;    
    
    return self;
    
}

- (id)cancel
{
    [self.connection cancel];
    self.connection = nil;
    self.downloadData = nil;    
    return self;
}

- (id)pause 
{
    NSArray *array = [NSArray arrayWithArray:self.failBlocks];
    self.failBlocks = [NSMutableArray array];
    [self.connection cancel];
    self.failBlocks = [NSMutableArray arrayWithArray:array];
    return self;
}

- (void)addCompletionBlock:(CompletionBlock)completion {
    [self.completionBlocks addObject:[completion copy]];
}

- (void)addFailBlock:(FailBlock)failBlock {
    [self.failBlocks addObject:[failBlock copy]];
}

- (void)addUpdateBLock:(UpdateBlock)block {
    [self.updateBlocks addObject:[block copy]];
}

- (BOOL)isWritingToDisk
{
    if (self.savePath == nil || [self.savePath isEqualToString:@""]) return FALSE;
    return TRUE;
}

- (BOOL)isEqualToDownload:(Download *)download
{
    if ([self.url.absoluteString isEqualToString:download.url.absoluteString]) return TRUE;
    return FALSE;
}
/*
 - (BOOL)downloadHasBeenStarted
 {
 BOOL result = FALSE;
 
 if (self.downloadData.length > 0) result = TRUE;
 
 //Get filesize
 if ([self isWritingToDisk]) {
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSDictionary *attributes = [fileManager attributesOfItemAtPath:self.savePath error:nil];
 if (attributes) {
 NSNumber *size = [attributes objectForKey:NSFileSize];
 if (size > 0) return TRUE;
 }
 }
 return FALSE;
 }
 */
- (BOOL)downloadIsActive
{
    return (self.connection) ? TRUE : FALSE;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedSize = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    amountDownloaded += data.length;
    self.progress = amountDownloaded/expectedSize;
    if (self.savePath == nil || [self.savePath isEqualToString:@""]) {
        [self.downloadData appendData:data];
    }
    else {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.savePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[handle closeFile];
    
	// Clear the activeDownload property to allow later attempts
    self.downloadData = nil;
    
    // Release the connection now that it's finished
    self.connection = nil;
    
    for (FailBlock block in self.failBlocks) {
        block(self,error);
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //[handle closeFile];
    NSData *data = [NSData dataWithData:self.downloadData.copy];
    for (CompletionBlock block in self.completionBlocks) {
        block(self,data);
    }
}

- (NSMutableData *)downloadData {
    if (!_downloadData) self.downloadData = [NSMutableData data];
    return _downloadData;
}

@end
