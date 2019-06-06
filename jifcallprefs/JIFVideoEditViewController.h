// @import AVKit;
// @import Photos;

@class PlayerView, AVPlayerLooper, AVAsset, AVPlayerLayer;

@interface JIFVideoEditViewController : UIViewController <UIGestureRecognizerDelegate> {
    AVPlayerLayer *_playerLayer;
    PlayerView *_playerView;
    // AVPlayer *_currentPlayer;
    AVPlayerLooper *_avLooper;
    UIButton *_cancelButton;
    UIButton *_setButton;
    UIView *_overlayView;
    AVAsset *_asset;
    NSURL *_assetURL;
}

-(instancetype)initWithAssetURL:(NSURL *)assetURL;
@end

@interface UIApplication (DeprecatedButUsingAnyways)
-(void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;
@end