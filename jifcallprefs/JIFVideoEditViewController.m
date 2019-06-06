#include "JIFVideoEditViewController.h"
#import "Log.h"
#import "JIFPreferences.h"
#import "JIFSaver.h"

@import AVKit;
@import Photos;

@interface PlayerView : UIView {
    AVPlayerLayer *_playerLayer;
}
@property AVPlayer *player;
@property (nonatomic, readonly) AVPlayerLayer* playerLayer;
@end

@implementation JIFVideoEditViewController 
-(instancetype)initWithAssetURL:(NSURL *)assetURL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _assetURL = assetURL;
        _asset = [AVAsset assetWithURL:assetURL];
    }

    return self;
}

-(void)loadView {    

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view = containerView;
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _cancelButton.backgroundColor = UIColor.whiteColor;

    _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_setButton setTitle:@"Save" forState:UIControlStateNormal];
    [_setButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _setButton.backgroundColor = UIColor.whiteColor;

    [_setButton addTarget:self action:@selector(saveEdit) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    
    _playerView = [[PlayerView alloc] initWithFrame:CGRectZero];
    _playerLayer = _playerView.playerLayer;
    [containerView addSubview:_playerView];
    [self beginFetchingVideoForPlayerLayer];
    
    [containerView addSubview:_cancelButton];
    [containerView addSubview:_setButton];

    UIPinchGestureRecognizer *scaleRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self 
                                                            action:@selector(scalePlayerLayer:)];
    UIPanGestureRecognizer *moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(movePlayerLayer:)];
    moveRecognizer.maximumNumberOfTouches = 2;
    moveRecognizer.delegate = self;
    [_playerView addGestureRecognizer:scaleRecognizer];
    [_playerView addGestureRecognizer:moveRecognizer];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect viewFrame = self.view.bounds;
    CGFloat buttonHeight = 50;
    CGFloat buttonY = viewFrame.size.height - buttonHeight;
    CGFloat buttonWidth = CGRectGetMidX(viewFrame);
    _cancelButton.frame = CGRectMake(0, buttonY, buttonWidth, buttonHeight);
    _setButton.frame = CGRectMake(buttonWidth, buttonY, buttonWidth, buttonHeight);
    _playerView.frame = viewFrame;
    _playerLayer.frame = viewFrame;
    log("containerDidLayout");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication.sharedApplication setStatusBarHidden:true withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication.sharedApplication setStatusBarHidden:false withAnimation:UIStatusBarAnimationSlide];    
}

-(IBAction)cancelEdit {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction)saveEdit {
    JIFSaver *saver = [JIFSaver new];
    JIFPreferences *prefs = [JIFPreferences new];
    JIFModel *newModel = [JIFModel new];

    NSURL *destURL = [saver persistJIFAtURL:_assetURL newName:@"default"];
    newModel.videoURL = destURL;
    newModel.transform = _playerLayer.affineTransform;

    [prefs setJIFAsDefault:newModel];

    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)beginFetchingVideoForPlayerLayer {
    AVPlayerItem *backgroundVideo = [AVPlayerItem playerItemWithAsset:_asset];
	AVQueuePlayer *player = [AVQueuePlayer queuePlayerWithItems:@[backgroundVideo]];
	_avLooper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:backgroundVideo];
    _playerView.player = player;
    [player play];
}

-(IBAction)scalePlayerLayer:(UIPinchGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CALayer *layer = _playerLayer;
        CGRect bounds = layer.bounds;
        CGAffineTransform newTransform = layer.affineTransform;
        // CGPoint centerOfPinch = [layer convertPoint:[gesture locationInView:_playerView] fromLayer:_playerView.layer];
        CGPoint centerOfPinch = [layer convertPoint:[gesture locationInView:_playerView] fromLayer:_playerView.layer];
        centerOfPinch.x -= CGRectGetMidX(bounds);
        centerOfPinch.y -= CGRectGetMidY(bounds);

        // zoom at center of pinch gesture
        newTransform = CGAffineTransformTranslate(newTransform, centerOfPinch.x, centerOfPinch.y);
        CGFloat scale = gesture.scale;
        newTransform = CGAffineTransformScale(newTransform, scale, scale);
        newTransform = CGAffineTransformTranslate(newTransform, -centerOfPinch.x, -centerOfPinch.y);

        // We don't modify _playerView's transform because that would cause layout in the container view
        // so instead we change transform of the _playerLayer
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [layer setAffineTransform:newTransform];
        [CATransaction commit];

        gesture.scale = 1.0;
    }
}

-(IBAction)movePlayerLayer:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:_playerView];
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x, translation.y);

        CGAffineTransform newTransform = CGAffineTransformConcat(_playerLayer.affineTransform, translationTransform);

        [gesture setTranslation:CGPointZero inView:_playerView];

        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        _playerLayer.affineTransform = newTransform;
        // _playerLayer.position = newPosition;
        [CATransaction commit];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

@end

@implementation PlayerView
- (AVPlayer *)player {
    return _playerLayer.player;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
        [self.layer addSublayer:_playerLayer];
    }
    return self;
}
 
- (void)setPlayer:(AVPlayer *)player {
    _playerLayer.player = player;
}
@end