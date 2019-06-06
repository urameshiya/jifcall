@interface SBRemoteAlertAdapter
@property (nonatomic,weak,readonly) NSString * serviceBundleIdentifier; 
@end

@interface _SBRemoteAlertHostViewController
@property (nonatomic,copy) NSString * serviceClassName;                                                                //@synthesize serviceClassName=_serviceClassName - In the implementation block
@end

@interface PHInCallRootViewController: UIViewController
@property (nonatomic, retain) AVPlayerViewController *jif_playerVC;
@property (nonatomic, retain) AVPlayerLooper *jif_playerLooper;
-(void)jif_playBackgroundVideo;


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

+(instancetype)sharedInstance;

@end