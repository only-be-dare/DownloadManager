//
//  Download.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-03.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface Download : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

typedef void(^CompletionBlock)(Download *download, NSData*data);
typedef void(^UpdateBlock)(float percentage);
typedef void(^FailBlock)(Download *download, NSError*error);

+ (id)downloadFromURLString:(NSString *)urlString writeToPath:(NSString *)path;
//+ (id)downloadFromURLString:(NSString *)urlString updateBlock:(UpdateBlock)block writeToPath:(NSString *)path;

- (BOOL)isWritingToDisk;
- (BOOL)isEqualToDownload:(Download *)download;
- (BOOL)downloadIsActive;

- (void)addCompletionBlock:(CompletionBlock)completion;
- (void)addFailBlock:(FailBlock)failBlock;
- (void)addUpdateBLock:(UpdateBlock)block;


- (id)start;
- (id)resume;
- (id)pause;
- (id)cancel;

@property (nonatomic, strong) NSMutableData     *downloadData;
@property (nonatomic, strong) NSURL             *url;
@property (nonatomic, strong, readonly) NSDate  *completionDate;
@property (nonatomic, strong) id                object;
@property (nonatomic, copy) NSString            *savePath;
@property (nonatomic, assign) float             progress;

@property (nonatomic, strong) NSMutableArray *completionBlocks;
@property (nonatomic, strong) NSMutableArray *updateBlocks;
@property (nonatomic, strong) NSMutableArray *failBlocks;
@property (nonatomic, strong) NSURLConnection *connection;
@end
