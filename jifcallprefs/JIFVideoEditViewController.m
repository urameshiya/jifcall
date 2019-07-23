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
    [AVAudioSession.sharedInstance setActive:false error:nil];  
}

-(IBAction)cancelEdit {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction)saveEdit {
    JIFPreferences *prefs = [JIFPreferences new];

    AVMutableComposition *noAudioComposition = [AVMutableComposition composition];
    AVAssetTrack *videoTrack = [_asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (videoTrack == nil) {
        log("Error getting video track from asset.");
        return;
    }
    NSError *error;
    AVMutableCompositionTrack *newTrack = [noAudioComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [newTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeZero error:&error];

    if (error) {
        log("Encountered an error while trying to extract video\n%@", error);
        return;
    }
    
    NSURL *destURL = [JIFSaver urlForJIFNamed:@"default"];
    JIFSaver *saver = [[JIFSaver alloc] initWithDestinationURL:destURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:noAudioComposition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = saver.tempURL;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.error) {
            log("Encountered an error during export\n%@", exportSession.error);
            [self dismissViewControllerAnimated:true completion:nil];
            return;
        }

        NSError *error;
        [saver finalizeFileWithError:&error];
        if (error) {
            log("Error saving file\n%@", error);
            [self dismissViewControllerAnimated:true completion:nil];
            return;
        }

        JIFModel *newModel = [JIFModel new];
        newModel.videoURL = destURL;
        newModel.transform = _playerLayer.affineTransform;

        [prefs setJIFAsDefault:newModel];
        [self dismissViewControllerAnimated:true completion:nil];
    }];

}

-(void)beginFetchingVideoForPlayerLayer {
    AVPlayerItem *backgroundVideo = [AVPlayerItem playerItemWithAsset:_asset];
	AVQueuePlayer *player = [AVQueuePlayer queuePlayerWithItems:@[backgroundVideo]];
	_avLooper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:backgroundVideo];
    _playerView.player = player;
    AVAudioSession *session = AVAudioSession.sharedInstance;

    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    [session setActive:true error:&error];

    if (error) {
        log("Error activating AVAudioSession %@", error);
    }
    player.muted = true;
    [player play];
}

-(IBAction)scalePlayerLayer:(UIPinchGestureRecognizer*)gesture {
    CALayer *layer = _playerLayer;

    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
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
    } else {
        CGFloat layerTransformedWidth = CGRectGetWidth(layer.frame);
        CGFloat constraintWidth = CGRectGetWidth(self.view.bounds);
        
        // resize image to fit screen
        if (layerTransformedWidth < constraintWidth) { // image is smaller than screen, assuming aspect ratio is kept
            layer.affineTransform = CGAffineTransformIdentity; // no need to care about translation
        }
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
    } else {
        CGRect constraintRect = self.view.bounds;
        CGRect layerFrame = _playerLayer.frame;
        CALayer *layer = _playerLayer;

        CGFloat offsetX = 0;
        CGFloat offsetY = 0;

        if (CGRectGetWidth(layerFrame) < CGRectGetWidth(constraintRect)) {
            return;  // if image is smaller than screen then scale gesture will handle it;
        }

        if (CGRectGetMinX(layerFrame) > 0) {
            offsetX = 0 - CGRectGetMinX(layerFrame);
        }
        else if (CGRectGetMaxX(layerFrame) < CGRectGetMaxX(constraintRect)) {
            offsetX =  CGRectGetMaxX(constraintRect) - CGRectGetMaxX(layerFrame);
        }

        if (CGRectGetMinY(layerFrame) > 0) {
            offsetY = 0 - CGRectGetMinY(layerFrame);
        }
        else if (CGRectGetMaxY(layerFrame) < CGRectGetMaxY(constraintRect)) {
            offsetY =  CGRectGetMaxY(constraintRect) - CGRectGetMaxY(layerFrame);
        }

        layer.affineTransform = CGAffineTransformConcat(layer.affineTransform, CGAffineTransformMakeTranslation(offsetX, offsetY));
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