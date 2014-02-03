

#import "CCProtocol.h"
#import <CommonCrypto/CommonKeyDerivation.h>

// Custom URL scheme name
NSString * const ENCRYPTED_FILE_SCHEME_NAME = @"encrypted-file";

static NSString *sharedKey = @"2ebd97a405abbd55b73f43ccae22b2b4";

// Buffer length - must be multiple of 16 for AES256
static const int BUFFER_LENGTH = 32 * 131072;

static NSString * const ERROR_DOMAIN = @"EncryptedFileURLProtocol";

enum ERROR_CODES {
    DECRYPTION_ERROR_CODE = 1
};

@interface CCProtocol ()

@property (nonatomic, strong) NSMutableData *muteData;

@end

@implementation CCProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	return ([[[request URL] scheme] isEqualToString:ENCRYPTED_FILE_SCHEME_NAME]);
}
	
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
	return request;
}

+ (void)setKey:(NSString *)key
{
    if (key != sharedKey)
    {
        sharedKey = [key copy];
    }
}
	
+ (NSString*)key
{
	return sharedKey;
}

- (void)startLoading
{
	inBuffer = malloc(BUFFER_LENGTH);
	outBuffer = malloc(BUFFER_LENGTH);
	
	//Create CCCryptor Object
	CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, [sharedKey cStringUsingEncoding:NSISOLatin1StringEncoding], kCCKeySizeAES256, NULL, &cryptoRef);
	
	inStream = [[NSInputStream alloc] initWithFileAtPath:[[self.request URL] path]];
	[inStream setDelegate:self];
	[inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inStream open];
}

- (void)stopLoading
{

	[inStream close];
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	inStream = nil;
	
	
	
	CCCryptorRelease(cryptoRef);
	free(inBuffer);
	free(outBuffer);
}
	
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
	switch(streamEvent) {
		case NSStreamEventNone:
		{
			NSLog(@"Stream Event None");
		}
			break;
		case NSStreamEventHasSpaceAvailable:
		{
			NSLog(@"Stream Event Has Space");
		}
			break;
		case NSStreamEventOpenCompleted:
		{
			NSLog(@"Stream Event Open");
		}
			break;
		case NSStreamEventHasBytesAvailable:
		{
			NSLog(@"Stream Event Bytes Available");

			size_t len = 0;
			len = [(NSInputStream *)inStream read:inBuffer maxLength:BUFFER_LENGTH];
			if (len)
			{
				// Decrypt CCCryptor Object
				if (kCCSuccess != CCCryptorUpdate(cryptoRef, inBuffer, len, outBuffer, BUFFER_LENGTH, &len))
				{
					[self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:ERROR_DOMAIN code:DECRYPTION_ERROR_CODE userInfo:nil]];
					return;
				}
				
				// Pass decrypted bytes on to URL loading system
				NSData *data = [NSData dataWithBytes:outBuffer length:len];

				[self.client URLProtocol:self didReceiveResponse:[NSURLResponse new] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
				[self.client URLProtocol:self didLoadData:data];
				[self.client URLProtocolDidFinishLoading:self];
			}
			break;
		}
		
		case NSStreamEventEndEncountered:
		{
			
			NSLog(@"Stream Event End Encountered");

			// Flush any remaining decrypted bytes
			size_t len = 0;
			CCCryptorFinal(cryptoRef, outBuffer, kCCBlockSizeAES128, &len);
			if (len)
			{
				NSData *data = [NSData dataWithBytesNoCopy:outBuffer length:len freeWhenDone:NO];
				
				[self.client URLProtocol:self didLoadData:data];

			}
			
			[self.client URLProtocolDidFinishLoading:self];
			break;
		}
		case NSStreamEventErrorOccurred:
		{
			NSLog(@"Stream Event Error");
			[self.client URLProtocol:self didFailWithError:[inStream streamError]];
			break;
		}
	
	}
}

@end
