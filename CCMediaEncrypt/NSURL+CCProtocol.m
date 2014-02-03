

#import "NSURL+CCProtocol.h"
#import "CCProtocol.h"

@implementation NSURL (CCProtocol)

+ (id)encryptedFileURLWithPath:(NSString *)path
{
	NSLog(@"Path Established");
	
    NSString *urlString = [[NSString stringWithFormat:@"%@://%@", ENCRYPTED_FILE_SCHEME_NAME, path] stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
	
	return [NSURL URLWithString:urlString];
}

@end
