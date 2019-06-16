@import AVKit;
#import "Tweak.h"
#import "jifcallprefs/JIFPreferences.h"
#import "jifcallprefs/JIFModel.h"
#import "Springboard.h"
#import "SBUIRemoteAlertHostInterface.h"
#import "SBUIRemoteAlertServiceInterface.h"

#import "notify.h"
#import <os/log.h>
#define log(s, ...) os_log(OS_LOG_DEFAULT, "__jifcall__ " s, ##__VA_ARGS__)
#define log_function() log("%{public}@ was sent", NSStringFromSelector(_cmd))

#define InCallServiceRemoteControllerClass @"PHInCallRemoteAlertShellViewController"
#define InCallServiceBundleID 			   @"com.apple.InCallService"

static CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
#define InCallNotification CFSTR("zzz.canisitis.jifcall.callIncoming")

static JIFPreferences *prefs;
static BOOL showingBanner = false;
static CGFloat bannerHeight = 100;
static bool incomingCallExists();

%group IncomingCallJIF

%hook PHInCallRemoteAlertShellViewController 
%end

%hook PHInCallRootViewController
%property (nonatomic, retain) AVPlayerViewController *jif_playerVC;
%property (nonatomic, retain) AVPlayerLooper *jif_playerLooper;

-(void)viewDidLoad {	
	%orig;	
	UIView *view = self.view;
	JIFModel *chosenJIF = [prefs defaultJIF];
	if (!chosenJIF) {
		return;
	}

	AVPlayerViewController* playerVC = [[AVPlayerViewController alloc] init];

	NSURL *assetURL = chosenJIF.videoURL;
	AVAsset *asset = [AVAsset assetWithURL:assetURL];
	AVPlayerItem *backgroundVideo = [AVPlayerItem playerItemWithAsset:asset];
	AVQueuePlayer *player = [[AVQueuePlayer alloc] init];
	AVPlayerLooper *looper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:backgroundVideo];

	playerVC.showsPlaybackControls = false;
	playerVC.player = player;
	playerVC.view.transform = chosenJIF.transform;

	player.muted = true;

	self.jif_playerLooper = looper;
	self.jif_playerVC = playerVC;

	view.clipsToBounds = true;
	view.userInteractionEnabled = true;
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandBanner)];
	[view addGestureRecognizer:tapGesture];
}

%new
-(void)expandBanner {
	// UIViewController *playerVC = self.playerVC;
	UIView *playerView = self.jif_playerVC.view;

	[UIView animateWithDuration:0.5 animations:^{
		self.view.frame = UIScreen.mainScreen.bounds;
		playerView.center = self.view.center;
	} completion: ^(BOOL finished){
		showingBanner = false;
	}];
}

-(void)callViewControllerStateChangedNotification:(NSNotification*)arg1 {
	%orig;

	TUCallCenter *callCenter = [%c(TUCallCenter) sharedInstance];
	AVPlayerViewController *playerVC = self.jif_playerVC;

	if ([callCenter incomingCall]) {
		[self jif_playBackgroundVideo];
		[self showBanner];
	} else {
		if (playerVC.parentViewController) {
			[playerVC.player pause];
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
	self.view.bounds = CGRectMake(0, 0, 375, bannerHeight);

	UIView* playerView = playerVC.view;
	AVPlayer *player = playerVC.player;

	player.muted = true;
	player.volume = 0;

	[self addChildViewController:playerVC];
	[view insertSubview:playerView atIndex:0];
	playerView.bounds = UIScreen.mainScreen.bounds;
	playerView.center = CGPointMake(375.0/2, 50);
	[player play];
}

%new
-(void)showBanner {
	self.view.center = CGPointMake(375.0/2, -bannerHeight/2);
	id currentCallVC = self.currentViewController;
	if (currentCallVC == self.audioCallNavigationController) {
		showingBanner = true;

		[(id)self.audioCallViewController showBanner];
		[UIView animateWithDuration:0.5 animations:^{
			self.view.center = CGPointMake(375.0/2, bannerHeight/2);
		} completion:nil];
	}
}
%end

%hook PHInCallRootView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (showingBanner) {
		return self;
	}
	return %orig;
}
%end

%hook PHCallViewController
%new
-(void)showBanner {
	// PHBottomBar *bottomBar = self.bottomBar;
	// bottomBar.mainLeftButton.hidden = false;
	// bottomBar.mainRightButton.hidden = false;
	// bottomBar.slidingButton.hidden = true;
	// bottomBar.supplementalTopLeftButton.hidden = true;
	// bottomBar.supplementalTopRightButton.hidden = true;
}
%end

%end


%group JIFButtonColors

#define CallStateIncoming 1
#define CallStateOutgoing 2
#define CallStateInterrupting 3

%hook PHCallViewController

-(void)setCurrentState:(short)state {
	%orig;
	log("State changed %d", state);
	PHBottomBar *bottomBar = self.bottomBar;
	if (state == CallStateIncoming) {
		PHActionSlider *acceptButton = bottomBar.slidingButton.acceptButton;
		bottomBar.supplementalTopLeftButton.backgroundColor = UIColor.purpleColor; // remind
		bottomBar.supplementalTopRightButton.backgroundColor = UIColor.purpleColor; // message
		bottomBar.supplementalTopLeftButton.layer.cornerRadius = 5;
		bottomBar.supplementalTopRightButton.layer.cornerRadius = 5;
		bottomBar.supplementalTopLeftButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_UIGlintyStringView *glintyView = (_UIGlintyStringView *) acceptButton.subviews[0].subviews[1];
		UIImage *tintableImage = [glintyView.shimmerImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		glintyView.shimmerImageView.image = tintableImage;
		glintyView.shimmerImageView.tintColor = UIColor.redColor;
	}
}

%new
-(void)jif_personalizeIncomingCallView {
}

%end

%end

%group SpringBoardServer

%hook SBMainWorkspace
-(bool)_executeAlertTransitionRequest:(SBWorkspaceTransitionRequest *)request {
	if (!incomingCallExists()) {
		return %orig;
	}
	SBAlert *alert = request.alertContext.alertToActivate.alert;
	if (![alert matchesAnyInCallService]) {
		return %orig;
	}
	log("Hijacking incoming call alert activation");

	[alert setAlertManager:self.alertManager];
	[alert setAlertDelegate:self.alertManager];

	[self.alertManager _createAlertWindowIfNecessaryForAlert:alert];

	[self.alertManager jif_activate:alert];
	return true;
}
%end

%hook SBAlertWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	log("Alert Window %@", self);
	if (showingBanner) {
		return point.y <= bannerHeight; // TODO: might not be able to touch other alerts but not my problem
	} 
	return %orig;
}
%end

%hook SBAlertManager

%new
-(void)jif_activate:(SBAlert *)alert {
	NSMutableArray *alerts = MSHookIvar<NSMutableArray *>(self, "_alerts");
	[alerts insertObject:alert atIndex:0];

	// Foregrounding InCallService is required to show the remote view
	FBScene *serverScene = MSHookIvar<FBScene *>(self, "_alertServerScene");
	log("Server settings %@", serverScene.settings);
	[serverScene updateSettingsWithBlock:^(FBSMutableSceneSettings *newSettings) {
		[newSettings setBackgrounded:NO];
	}];

	[self.alertWindow displayAlert:alert];
	[alert activate];

	[self.alertWindow makeKeyAndVisible];
}

%end

%hook _SBRemoteAlertHostViewController
-(void)setWallpaperTunnelActive:(bool)arg {
	if ([self alertMatchesInCallServiceAndIncomingCallExists]) {
		%orig(false);
		return;
	}
	%orig;
}

-(void)setBackgroundMaterialDescriptor:(id)arg {
	if ([self alertMatchesInCallServiceAndIncomingCallExists]) {
		return;
	}
	%orig;
}

-(void)setBackgroundWeighting:(double)arg1 animationsSettings:(id)arg2 {
	if ([self alertMatchesInCallServiceAndIncomingCallExists]) {
		return;
	}
	%orig;
}

-(void)setBackgroundStyle:(int)arg1 withDuration:(double)arg2 {
	if ([self alertMatchesInCallServiceAndIncomingCallExists]) {
		return;
	}
	%orig;
}

%new
-(bool)alertMatchesInCallServiceAndIncomingCallExists {
	return [self.serviceClassName isEqualToString:InCallServiceRemoteControllerClass] && incomingCallExists();
}
%end

%end // End group SpringboardServer

%ctor {
	prefs = [[JIFPreferences alloc] init];
	if (!prefs.enabled) {
		return;
	}
	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;

	if (IN_SPRINGBOARD) {
		%init(SpringBoardServer);
		log("set up SpringBoard");
	}

    if ([bundleID isEqualToString:InCallServiceBundleID]) {
        %init(IncomingCallJIF);
        %init(JIFButtonColors);
        log("hooked into InCallService");
    } else {
        %init(_ungrouped);
        log("loaded");
        }
}


@implementation JIFAlertWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (showingBanner) {
		return point.y < 200; // TODO: might not be able to touch other alerts so fix that
	} 
	return [super pointInside:point withEvent:event];
}
@end

static TUCallCenter *callCenter = [%c(TUCallCenter) sharedInstance];

static bool incomingCallExists() {
	log("incoming call %@", [callCenter incomingCall]);
	return [callCenter incomingCall] != nil;
}