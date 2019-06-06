@import AVKit;
#import "Tweak.h"
#import "jifcallprefs/JIFPreferences.h"
#import "jifcallprefs/JIFModel.h"

#import <os/log.h>
#define log(s, ...) os_log(OS_LOG_DEFAULT, "__jifcall__ " s, ##__VA_ARGS__)
#define log_function() log("%{public}@ was sent", NSStringFromSelector(_cmd))

static JIFPreferences *prefs = [[JIFPreferences alloc] init];

%group IncomingCallJIF

%hook PHInCallRootViewController
%property (nonatomic, retain) AVPlayerViewController *jif_playerVC;
%property (nonatomic, retain) AVPlayerLooper *jif_playerLooper;

-(void)viewDidLoad {	
	%orig;	
	if (!prefs.enabled) {
		return;
	}

	AVPlayerViewController* playerVC = [[AVPlayerViewController alloc] init];

	// NSString *urlString = @"file:///var/mobile/Media/DCIM/101APPLE/IMG_1514.mp4";
	// NSURL *assetURL = [NSURL URLWithString:urlString];
	// log("Reached here");
	JIFModel *chosenJIF = [prefs defaultJIF];
	// if ([prefs objectForKey:@"default"] == nil) {
	// 	log("Cannot find him.");
	// }
	NSURL *assetURL = chosenJIF.videoURL;
	AVAsset *asset = [AVAsset assetWithURL:assetURL];
	AVPlayerItem *backgroundVideo = [AVPlayerItem playerItemWithAsset:asset];
	AVQueuePlayer *player = [[AVQueuePlayer alloc] init];
	AVPlayerLooper *looper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:backgroundVideo];

	playerVC.showsPlaybackControls = false;
	playerVC.player = player;
	playerVC.view.transform = chosenJIF.transform;

	player.muted = true;
	
	// UIView* view = self.view;
	// UIView* playerView = playerVC.view;

	// [self addChildViewController:playerVC];
	// [view insertSubview:playerView atIndex:0];
	// playerView.frame = view.bounds;
	
	// [player play];

	self.jif_playerLooper = looper;
	self.jif_playerVC = playerVC;

}

-(void)callViewControllerStateChangedNotification:(NSNotification*)arg1 {
	%orig;

	TUCallCenter *callCenter = [%c(TUCallCenter) sharedInstance];
	AVPlayerViewController *playerVC = self.jif_playerVC;

	if ([callCenter incomingCall]) {
		[self jif_playBackgroundVideo];
	} else {
		if (playerVC.parentViewController) {
			[playerVC willMoveToParentViewController:nil];
			[playerVC.view removeFromSuperview];
			[playerVC removeFromParentViewController];
		}
	}
}

%new
-(void)jif_playBackgroundVideo {
	AVPlayerViewController *playerVC = self.jif_playerVC;
	UIView* view = self.view;
	UIView* playerView = playerVC.view;
	AVPlayer *player = playerVC.player;
	

	[self addChildViewController:playerVC];
	[view insertSubview:playerView atIndex:0];
	playerView.bounds = view.bounds;
	playerView.center = self.view.center;
	[player play];
}
%end

%end

%ctor {
	if (prefs.enabled) {
		%init(IncomingCallJIF);
		log("loaded");
	}
}