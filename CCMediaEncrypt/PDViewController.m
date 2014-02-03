

#import "PDViewController.h"
#import "NSURL+CCProtocol.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HTTPConnection.h"
#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

static const NSString *ItemStatusContext;



@interface PDViewController ()
{
	BOOL isFileSaved;
	NSMutableData *aData;
	NSURL *movieURL;
	NSString *moviePath;
	AVPlayer *player;
	AVPlayerItem *playerItem;
	CMTime segment;
}

@property (weak, nonatomic) IBOutlet AVPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self syncUI];
		
	// Load an encrypted resource into NSData object
	NSURL *aURL = [NSURL encryptedFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png" inDirectory:@"CCResources"]];
	
	NSError *error;
	NSData *data = [NSData dataWithContentsOfURL:aURL options:NSDataReadingUncached error:&error];
	if (!error) {
		UIImage *image = [UIImage imageWithData:data];
		self.imageView.image = image;
	
	}
	
	
	
	movieURL = [NSURL URLWithString:@"http://127.0.0.1:53321/prog_index.m3u8"];

	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];
	NSString *tracksKey = @"tracks";
	
	[asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^{
		
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   NSError *error;
						   AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
						   
						   if (status == AVKeyValueStatusLoaded) {
							   playerItem = [AVPlayerItem playerItemWithAsset:asset];
							   [playerItem addObserver:self forKeyPath:@"status"
											   options:0 context:&ItemStatusContext];
							   [[NSNotificationCenter defaultCenter] addObserver:self
																		selector:@selector(playerItemDidReachEnd:)
																			name:AVPlayerItemDidPlayToEndTimeNotification
																		  object:playerItem];
							   player = [AVPlayer playerWithPlayerItem:playerItem];
							   [self.playerView setPlayer:player];
						   }
						   else {
							   // You should deal with the error appropriately.
							   NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
						   }
					   });
	}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
	
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
						   change:change context:context];
    return;
}

- (void)syncUI {
    if ((player.currentItem != nil) &&
        ([player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {

    }
    else {

    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
	
	[player play];
}


- (IBAction)stop:(id)sender {
	
	[player pause];
}

- (IBAction)forward:(id)sender {
	
	CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime) + 5, player.currentTime.timescale);
	[player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (IBAction)back:(id)sender {
	
	CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime) - 5, player.currentTime.timescale);
	[player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (NSString *)destinationPath:(NSString *)component
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:component];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [player seekToTime:kCMTimeZero];
}


@end
