//
//  Download.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-03.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^CompletionBlock)(NSString*url, NSData*data, NSDate*completionDate);
typedef void(^FailBlock)(NSString*url, NSError*error, NSDate*failDate);


@interface Download : NSObject

+ (Download *)downloadFromURLString:(NSString *)urlString;

- (BOOL)isEqualToDownload:(Download *)download;
- (void)addCompletionBlock:(CompletionBlock)completion;
- (void)addFailBlock:(FailBlock)failBlock;


- (id)start;
- (id)cancel;

@property (nonatomic, strong) NSMutableData     *activeDownload;
@property (nonatomic, strong) NSURL             *url;
@property (nonatomic, strong, readonly) NSDate  *completionDate;
@end
