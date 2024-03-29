/*
* This header is generated by classdump-dyld 1.0
* on Friday, February 8, 2019 at 1:51:38 PM Eastern European Standard Time
* Operating System: Version 12.1 (Build 16B92)
* Image Source: /System/Library/CoreServices/SpringBoard.app/SpringBoard
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/


@protocol SBUIRemoteAlertHostInterface
@required
-(void)setWhitePointAdaptivityStyle:(long long)arg1;
-(void)dismiss;
-(void)setAllowsAlertItems:(BOOL)arg1;
-(void)setAllowsMenuButtonDismissal:(BOOL)arg1;
-(void)setBackgroundStyle:(long long)arg1 withDuration:(double)arg2;
-(void)setBackgroundMaterialDescriptor:(id)arg1;
-(void)setBackgroundWeighting:(double)arg1 animationsSettings:(id)arg2;
-(void)setAllowsAlertStacking:(BOOL)arg1;
-(void)setDesiredStatusBarStyleOverrides:(int)arg1;
-(void)setStyleOverridesToCancel:(int)arg1 animationSettings:(id)arg2;
-(void)setStatusBarHidden:(BOOL)arg1 withDuration:(double)arg2;
-(void)setShouldDisableFadeInAnimation:(BOOL)arg1;
-(void)setOrientationChangedEventsEnabled:(BOOL)arg1;
-(void)setIdleTimerDisabled:(BOOL)arg1 forReason:(id)arg2;
-(void)setAllowsBanners:(BOOL)arg1;
-(void)setShouldDismissOnUILock:(BOOL)arg1;
-(void)setDesiredHardwareButtonEvents:(unsigned long long)arg1;
-(void)setSwipeDismissalStyle:(long long)arg1;
-(void)setDismissalAnimationStyle:(long long)arg1;
-(void)setSupportedInterfaceOrientationOverride:(unsigned long long)arg1;
-(void)setDesiredAutoLockDuration:(double)arg1;
-(void)setWallpaperStyle:(long long)arg1 withDuration:(double)arg2;
-(void)setLaunchingInterfaceOrientation:(long long)arg1;
-(void)setWallpaperTunnelActive:(BOOL)arg1;

@end

@protocol JIFRemoteAlertHostInterface <SBUIRemoteAlertHostInterface>
-(void)setShowingBanner:(BOOL)showBanner;
@end

