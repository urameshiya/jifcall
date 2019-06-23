#import "_UIRemoteViewController.h"
#import "SBUIRemoteAlertHostInterface.h"
#import <Foundation/NSXPCInterface.h>
#import "JIFBannerOverlay.h"


@interface SBRemoteAlertAdapter
@property (nonatomic,weak,readonly) NSString * serviceBundleIdentifier; 
-(UIViewController *)effectiveViewController;
-(void)setWallpaperTunnelActive:(bool)arg;
@end

@interface _SBRemoteAlertHostViewController: UIViewController <JIFRemoteAlertHostInterface>
@property (nonatomic,copy) NSString * serviceClassName;                                                       

-(id)delegate;

// ADDED
-(bool)alertMatchesInCallServiceAndIncomingCallExists;
@end

@interface PHCallParticipantsView: UIView
@end

@interface PHCallParticipantsViewController: UIViewController
@property (retain) PHCallParticipantsView * participantsView;                            //@synthesize participantsView=_participantsView - In the implementation block
@end

@interface PHInCallRootView: UIView
@end

@interface PHInCallRootViewController: UIViewController
@property (nonatomic, retain) AVPlayerViewController *jif_playerVC;
@property (nonatomic, retain) AVPlayerLooper *jif_playerLooper;
@property (nonatomic, retain) JIFBannerOverlay *jif_bannerOverlay;
-(void)jif_playBackgroundVideo;
-(void)showBanner;
-(void)expandBanner;
-(void)loadBackgroundVideoIfNeeded;
-(id<SBUIRemoteAlertHostInterface>)_remoteViewControllerProxy;

// PRIVATE
@property (nonatomic,retain) UIViewController * audioCallViewController;                                 //@synthesize audioCallViewController=_audioCallViewController - In the implementation block
@property (nonatomic,retain) UIViewController * currentViewController; 
@property (retain) UINavigationController * audioCallNavigationController;
@property (nonatomic,retain) UINavigationController * videoCallNavigationController;  
-(void)requestInCallDismissalWithAnimation:(BOOL)arg1 ;
@end

@interface PHActionSlider: UIControl
@property (assign,getter=isAnimating,nonatomic) BOOL animating;                              //@synthesize animating=_animating - In the implementation block
@property (nonatomic,copy) NSString * trackText;                                             //@synthesize trackText=_trackText - In the implementation block

-(void)setBackgroundColor:(id)arg1 ;

@end

@interface _UIGlintyStringView : UIView
@property BOOL hasCustomBackgroundColor;
@property (nonatomic,retain) UIImageView * shimmerImageView;                               //@synthesize shimmerImageView=_shimmerImageView - In the implementation block


@end

@interface PHSlidingButton: UIView
@property (retain) PHActionSlider * acceptButton;                             //@synthesize acceptButton=_acceptButton - In the implementation block

@end

@interface PHBottomBar: UIView
@property (retain) NSArray * buttonLayoutConstraints;
@property (nonatomic,retain) UIButton * supplementalTopLeftButton;                     //@synthesize supplementalTopLeftButton=_supplementalTopLeftButton - In the implementation block
@property (nonatomic,retain) UIButton * supplementalTopRightButton;                    //@synthesize supplementalTopRightButton=_supplementalTopRightButton - In the implementation block
@property (nonatomic,retain) UIButton * mainLeftButton;                                //@synthesize mainLeftButton=_mainLeftButton - In the implementation block
@property (nonatomic,retain) UIButton * mainRightButton;                               //@synthesize mainRightButton=_mainRightButton - In the implementation block
@property (nonatomic,retain) UIButton * sideButtonLeft;                                //@synthesize sideButtonLeft=_sideButtonLeft - In the implementation block
@property (nonatomic,retain) UIButton * sideButtonRight;                               //@synthesize sideButtonRight=_sideButtonRight - In the implementation block
@property (nonatomic,retain) UIButton * supplementalBottomRightButton;                 //@synthesize supplementalBottomRightButton=_supplementalBottomRightButton - In the implementation block
@property (nonatomic,retain) UIButton * supplementalBottomLeftButton;  
@property (nonatomic,retain) PHSlidingButton * slidingButton;                          //@synthesize slidingButton=_slidingButton - In the implementation block
-(void)setCurrentState:(long long)state;

// ADDED
-(void)updateLayoutConstraintsForBanner;
@end

// This guy is for both incoming and outgoing calls
@interface PHCallViewController: UIViewController
@property (nonatomic,retain) PHBottomBar * bottomBar;

//ADDED
-(void)bannerWillShow;
-(void)bannerWillExpand;
@end

@interface NSObject (Private)
- (NSString *)className;

@end

@interface UIView (Private)
-(NSString *)recursiveDescription;
@end

@interface AVPlayerController
-(void)setHandlesAudioSessionInterruptions:(BOOL)arg1;
@end

@interface AVPlayerViewController (Private)
-(AVPlayerController *)playerController;

@end

@interface TUCallCenter
@property (nonatomic,readonly) id incomingCall; 
@property (nonatomic,readonly) id incomingVideoCall; 
@property (nonatomic,readonly) id frontmostCall; 
+(instancetype)sharedInstance;
-(void)answerCall:(id)call;
-(void)disconnectCall:(id)arg1 withReason:(int)arg2;
@end

// @interface _UIRemoteViewController
// +(id)requestViewController:(id)arg1 fromServiceWithBundleIdentifier:(id)arg2 connectionHandler:(/*^block*/id)arg3;

// @end

@interface NSXPCInterface (Private)
- (void)setClasses:(NSSet<Class> *)classes 
       forSelector:(SEL)sel 
     argumentIndex:(NSUInteger)arg 
           ofReply:(BOOL)ofReply;

- (NSSet<Class> *)classesForSelector:(SEL)sel 
                       argumentIndex:(NSUInteger)arg 
                             ofReply:(BOOL)ofReply;
@end

@interface _UIRemoteView: UIView

@end

@interface JIFAlertWindow: UIWindow
@end

@protocol JIFBannerDisplaying
-(void)showBanner;
@end

@interface PHInCallRootViewController (Private) <JIFBannerOverlayDelegate>
@end