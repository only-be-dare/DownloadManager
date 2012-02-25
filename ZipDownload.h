//
//  ZipDownload.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-02-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Download.h"

@interface ZipDownload : Download

@property (nonatomic, copy) NSString *unzipPath;
@property (nonatomic, strong) NSString *fullUnzipPath;
@end
