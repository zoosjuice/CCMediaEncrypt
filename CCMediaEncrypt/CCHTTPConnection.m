

#import "CCHTTPConnection.h"
#import "CCHTTPFileResponse.h"

@implementation CCHTTPConnection

-(NSObject<HTTPResponse>*) httpResponseForMethod:(NSString *)method URI:(NSString *)path{
	
    return [[CCHTTPFileResponse alloc] initWithFilePath:[self filePathForURI:path] forConnection:self];
}

@end
