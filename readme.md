__Readme__

This is a small class I created in a afternoon, which never got a lot of debugging. Treat it like one. __Enter at your peril!__ Feel free to fork and send pull requests.

__Features__

- Downloads will be added to a queue where one is downloaded at a time
- If you try to download contents from the exact same url twice, it will in fact only be downloaded once 

__How to use:__
 
    #import "DownloadManager.h"


And then:

	NSString *urlString = @"..";
    [[DownloadManager defaultManager] addDownload:[Download downloadFromURLString:urlString] 
    withCompletion:^(NSString *url,NSData *data, NSDate *completionDate) {
		//Do something with the data!
    }];

/Johannes Lund
 