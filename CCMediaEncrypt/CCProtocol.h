

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

extern NSString * const ENCRYPTED_FILE_SCHEME_NAME;

@interface CCProtocol : NSURLProtocol <NSStreamDelegate>{
	
	NSInputStream *inStream;
	NSOutputStream *outStream;
    uint8_t *inBuffer;
    uint8_t *outBuffer;
    CCCryptorRef cryptoRef;
}

+ (NSString*)key;

@end
