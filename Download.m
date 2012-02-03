//
//  Download.m
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-03.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import "Download.h"

@interface Download()
- (void)startDownloadingURL:(NSURL *)url_;
@property (nonatomic, strong) NSMutableArray *completionBlocks;
@property (nonatomic, strong) NSMutableArray *failBlocks;

@property (nonatomic, strong) NSURLConnection *imageConnection;
@end

@implementation Download
@synthesize url, completionBlocks, imageConnection,activeDownload, failBlocks, completionDate;

+ (Download *)downloadFromURLString:(NSString *)urlString
{
    Download *download = [[Download alloc] init];
    download.url = [NSURL URLWithString:urlString];
    download.completionBlocks = [NSMutableArray array];
    download.failBlocks = [NSMutableArray array];
    
    return download;
}

- (id)start
{

    [self startDownloadingURL:self.url];
    return self;
}

- (id)cancel
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;    
    return self;
}

- (void)addCompletionBlock:(CompletionBlock)completion {
    [self.completionBlocks addObject:[completion copy]];
}

- (void)addFailBlock:(FailBlock)failBlock {
    [self.failBlocks addObject:[failBlock copy]];
}

- (BOOL)isEqualToDownload:(Download *)download
{
    if ([self.url.absoluteString isEqualToString:download.url.absoluteString]) return TRUE;
    return FALSE;
}

#pragma mark

- (void)startDownloadingURL:(NSURL *)url_
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url_ cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60] delegate:self];
    self.imageConnection = conn;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    for (FailBlock block in self.failBlocks) {
        block(self.url.absoluteString,error,[NSDate date]);
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSData *data = [NSData dataWithData:self.activeDownload.copy];
    for (CompletionBlock block in self.completionBlocks) {
        block(self.url.absoluteString,data,[NSDate date]);
    }
}

@end
