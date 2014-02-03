

#import "PDAppDelegate.h"
#import <CommonCrypto/CommonKeyDerivation.h>
#import "CCProtocol.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "CCHTTPConnection.h"

@interface PDAppDelegate ()


@end


@implementation PDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	
	[NSURLProtocol registerClass:[CCProtocol class]];
	
	self.localServer = [[HTTPServer alloc] init];
	[self.localServer setType:@"_http._tcp."];
	[self.localServer setPort:53321];
	[self.localServer setConnectionClass:[CCHTTPConnection class]];
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Server"];

	if ([[NSFileManager defaultManager] fileExistsAtPath:webPath isDirectory:NO]) {
		NSLog(@"File?");
	}else
		NSLog(@"No File?");
		
	[self.localServer setDocumentRoot:webPath];
	[self startServer];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[self.localServer stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startServer
{
    // Start the server (and check for problems)
	
	NSError *error;
	if([self.localServer start:&error])
	{
		NSLog(@"Started HTTP Server on port %hu", [self.localServer listeningPort]);
	
	}
	else
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}
}

- (NSString *)destinationPath:(NSString *)component
{
	return [[NSTemporaryDirectory() stringByAppendingPathExtension:@"Server"] stringByAppendingPathComponent:component];
}


@end
