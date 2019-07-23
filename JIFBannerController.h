@import AVFoundation;
#import "jifcallprefs/JIFModel.h"
#import "TelephonyUtilities.h"

@protocol JIFBannerControllerDelegate
-(void)bannerDidAccept;
-(void)bannerDidDecline;
@end

@interface JIFCallerLabel: UIView
@property (nonatomic, retain) UIVisualEffectView *blurBackgroundView;
@property (nonatomic, retain) UILabel *nameLabel;
@end

@interface JIFBannerController: UIViewController
@property (nonatomic, weak) id<JIFBannerControllerDelegate> delegate;
@property (nonatomic, retain) JIFModel* model;

@property (nonatomic, retain) UILabel *acceptButton;
@property (nonatomic, retain) UILabel *declineButton;
@property (nonatomic, retain) JIFCallerLabel *callerLabel;
@property (nonatomic, readonly) bool isInBannerForm;

-(void)peekBanner;
-(void)updateForCall:(TUCall *)call;
-(void)dismissBanner;
-(void)retractBannerAnimated:(BOOL)animated;
-(void)expandBanner;
-(void)presentForLockscreen;
@end

@interface UILabel (Private)
-(void)setMarqueeEnabled:(bool)arg;
-(void)setMarqueeRunning:(bool)arg;
@end
