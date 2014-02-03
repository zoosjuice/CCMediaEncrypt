

#import <UIKit/UIKit.h>
#import "HTTPConnection.h"
#import "HTTPServer.h"

@interface PDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) HTTPServer *localServer;


@end
