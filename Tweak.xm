@import AVKit;
#import "Tweak.h"
#import "jifcallprefs/JIFPreferences.h"
#import "jifcallprefs/JIFModel.h"
#import "Springboard.h"
// #import "SBUIRemoteAlertHostInterface.h"
#import "SBUIRemoteAlertServiceInterface.h"
#import "JIFWindow.h"

#import "notify.h"
#import <os/log.h>
#define log(s, ...) os_log(OS_LOG_DEFAULT, "__jifcall__ " s, ##__VA_ARGS__)
#define log_function() log("%{public}@ was sent", NSStringFromSelector(_cmd))

#define InCallServiceRemoteControllerClass @"PHInCallRemoteAlertShellViewController"
#define InCallServiceBundleID 			   @"com.apple.InCallService"

static CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
#define InCallNotification CFSTR("zzz.canisitis.jifcall.callIncoming")

static JIFPreferences *prefs;
// static BOOL showingBanner = false;
// static CGFloat bannerHeight = 100;
// static CGFloat bannerWidth = 375.0;
static bool incomingCallExists();
static TUCallCenter *callCenter = [%c(TUCallCenter) sharedInstance];
static SBAlert* currentInCallAlert;
static UIWindow *jif_window;
static JIFBannerController *bannerController;
static UIWindowLevel alertWindowLevel = [%c(SBAlertWindow) windowLevel];
// static bool pleaseShowBanner = false;

// static void resetGlobalVars() {
// 	showingBanner = false;
// }

static TUCall* incomingAudioOrVideoCall() { // TODO: Multiway?
	return [callCenter incomingCall] ?: [callCenter incomingVideoCall];
}

static BOOL isUILocked() {
	SBLockScreenManager *ls = [%c(SBLockScreenManager) sharedInstance];
	return [ls isUILocked];
}

%group JIFButtonColors

#define CallStateIncoming 1
#define CallStateOutgoing 2
#define CallStateInterrupting 3

%hook PHCallViewController

// -(void)setCurrentState:(short)state {
// 	%orig;
// 	log("State changed %d", state);
// 	PHBottomBar *bottomBar = self.bottomBar;
// 	if (state == CallStateIncoming) {
// 		PHActionSlider *acceptButton = bottomBar.slidingButton.acceptButton;
// 		bottomBar.supplementalTopLeftButton.backgroundColor = UIColor.purpleColor; // remind
// 		bottomBar.supplementalTopRightButton.backgroundColor = UIColor.purpleColor; // message
// 		bottomBar.supplementalTopLeftButton.layer.cornerRadius = 5;
// 		bottomBar.supplementalTopRightButton.layer.cornerRadius = 5;
// 		bottomBar.supplementalTopLeftButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
// 		_UIGlintyStringView *glintyView = (_UIGlintyStringView *) acceptButton.subviews[0].subviews[1];
// 		UIImage *tintableImage = [glintyView.shimmerImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
// 		glintyView.shimmerImageView.image = tintableImage;
// 		glintyView.shimmerImageView.tintColor = UIColor.redColor;
// 	}
// }

%end

%end

%group SpringBoardServer

%hook SBMainWorkspace
-(bool)_executeAlertTransitionRequest:(SBWorkspaceTransitionRequest *)request {
	log("_executeAlertTransition...");
	if (!incomingCallExists()) {
		return %orig;
	}
	SBAlert *alert = request.alertContext.alertToActivate.alert;
	if (![alert matchesAnyInCallService]) {
		return %orig;
	}
	log("Hijacking incoming call alert activation");

	JIFModel *chosenJIF = [prefs defaultJIF];
	if (!chosenJIF) {
		return %orig;
	}
	UIWindow* bannerWindow = jif_window;
	if (!bannerWindow) {
		bannerWindow = [[JIFWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
		bannerController = [[JIFBannerController alloc] init];
		bannerWindow.rootViewController = bannerController;
		bannerWindow.windowLevel = alertWindowLevel - 1;
		bannerController.delegate = self;
		jif_window = bannerWindow;
	}

	bannerWindow.hidden = false;
	[bannerController setModel:chosenJIF];
	[bannerController updateForCall:incomingAudioOrVideoCall()];

	if (isUILocked()) {
		// bannerWindow.windowLevel -= 1;
		[bannerController presentForLockscreen];
		%orig;
	} else {
		[bannerController peekBanner];
	}
	return true;
}

%new
-(void)bannerDidAccept {
	id incomingCall = incomingAudioOrVideoCall();
	if (!incomingCall) {
		log("No incoming call...");
		[bannerController dismissBanner];
		return;
	}
	[callCenter answerCall:incomingCall];
	[bannerController dismissBanner];
}

%new
-(void)bannerDidDecline {
	id incomingCall = incomingAudioOrVideoCall();
	if (!incomingCall) {
		log("No incoming call...");
		[bannerController dismissBanner];
		return;
	}
	[callCenter disconnectCall:incomingCall withReason:2];
	[bannerController dismissBanner];
}
%end

%hook SBAlertManager

%new
-(void)jif_activate:(SBAlert *)alert {
	NSMutableArray *alerts = MSHookIvar<NSMutableArray *>(self, "_alerts");
	[alerts removeObject:alert];
	[alerts insertObject:alert atIndex:0];

	// Foregrounding InCallService is required to show the remote view
	FBScene *serverScene = MSHookIvar<FBScene *>(self, "_alertServerScene");
	log("Server settings %@", serverScene.settings);
	[serverScene updateSettingsWithBlock:^(FBSMutableSceneSettings *newSettings) {
		[newSettings setBackgrounded:NO];
	}];

	[self.alertWindow displayAlert:alert];
	// [alert activate];

	// [self.alertWindow makeKeyAndVisible];
	[self.alertWindow setHidden:false];
}

%new
-(NSMutableArray *)mutableAlerts {
	return MSHookIvar<NSMutableArray *>(self, "_alerts");
}

%end

%hook SBHomeHardwareButtonActions
-(void)performSinglePressUpActions {
	if (!jif_window.hidden && bannerController != nil && !bannerController.isInBannerForm) {
		[bannerController retractBannerAnimated:true];
		return;
	}
	%orig;
}
%end

%hook SBAlertWallpaperTunnelManager
-(void)pushTunnelToWallpaperForAlert:(id)arg1 {
	BOOL isBannerWindowOriginallyHidden = jif_window.hidden;
	%orig;
	if (!isBannerWindowOriginallyHidden) {
		jif_window.hidden = false;
	}
}
%end

%hook _SBRemoteAlertHostViewController

%new
-(bool)alertMatchesInCallServiceAndIncomingCallExists {
	return [self.serviceClassName isEqualToString:InCallServiceRemoteControllerClass] && incomingCallExists();
}
%end

%hook SBTelephonyManager
-(void)callEventHandler:(NSNotification *)notification {
	// TUCall *call = (TUCall *) notification.object;

	if (!incomingCallExists()) {
		[bannerController dismissBanner];
	}
	
	%orig;
}
%end

// %hook TUCallNotificationManager
// -(void)statusChangedForCall:(id)arg1 {
// 	%log;
// }
// %end

%end // End group SpringboardServer

%ctor {
	prefs = [[JIFPreferences alloc] init];
	if (!prefs.enabled) {
		return;
	}
	// NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;

	if (IN_SPRINGBOARD) {
		%init(SpringBoardServer);
		log("set up SpringBoard");
	}
}

static bool incomingCallExists() {
	// log("incoming call %@", [callCenter incomingCall]);
	return [callCenter incomingCall] != nil || [callCenter incomingVideoCall] != nil;
}