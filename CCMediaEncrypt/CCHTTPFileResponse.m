

#import "CCHTTPFileResponse.h"

@implementation CCHTTPFileResponse

- (NSDictionary *)httpHeaders{
    NSString* contentType = @"";
    if([[filePath pathExtension] isEqualToString:@"ts"]){
        contentType = @"video/MP2T";
    }else if([[filePath pathExtension] isEqualToString:@"mov"]){
        contentType = @"video/quicktime";
	}else if([[filePath pathExtension] isEqualToString:@"m4v"]){
		contentType = @"video/x-m4v";
    }else if([[filePath pathExtension] isEqualToString:@"m3u8"]){
		contentType = @"application/x-mpegURL";
    }else if ([[filePath pathExtension] isEqualToString:@"key"]){
		contentType = @"text/plain";
	}else{
        return nil;
    }
	
    return @{@"Content-Disposition": [NSString stringWithFormat:@"attachment; filename=\"%@\"", [filePath lastPathComponent]],
             @"content-type" : contentType};
}

@end
