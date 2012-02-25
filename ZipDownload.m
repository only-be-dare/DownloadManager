//
//  ZipDownload.m
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZipDownload.h"
#import "ZipArchive.h"

@implementation ZipDownload
@synthesize unzipPath;
@synthesize fullUnzipPath;

+ (id)downloadFromURLString:(NSString *)urlString writeToPath:(NSString *)apath; 
{
    ZipDownload *download = [[ZipDownload alloc] init];
    download.url = [NSURL URLWithString:urlString];
    download.completionBlocks = [NSMutableArray array];
    download.failBlocks = [NSMutableArray array];
    download.savePath = apath;
    return download;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        //Download is complete
        //Begin the extracing process
        NSString*newString;
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        ZipArchive*zip = [[ZipArchive alloc] init];
        
        [zip UnzipOpenFile:self.savePath];
        
        newString = [zip UnzipFileTo:self.unzipPath overWrite:YES];
        if(newString)
        {
            //Success – remove zip archive
            [fileManager removeItemAtPath:self.savePath error:nil];
            
        }
        //Close file
        [zip UnzipCloseFile];
        //Set local URL
        dispatch_async(dispatch_get_main_queue(), ^{
      
            NSData *data = [NSData dataWithData:self.downloadData.copy];
            for (CompletionBlock block in self.completionBlocks) {
                block(self,data);
            }
            
        });
    });

}

@end
