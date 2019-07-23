#import "JIFBannerController.h"
#import "Log.h"

static CGFloat buttonWidth = 90;
static CGFloat buttonHeight = 30;

@interface PlayerView: UIView
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
-(void)setPlayer:(AVPlayer *)player;
@end

@implementation JIFBannerController {
    AVPlayer *_player;
    AVPlayerLooper *_looper;
    PlayerView *_playerView;
    NSLayoutConstraint *_expandedBannerConstraint;
    NSLayoutConstraint *_justOutsideWindowConstraint;
}

-(void)setModel:(JIFModel *)model {
    if ([_model isEqual:model]) {
        return;
    }
    NSURL *assetURL = model.videoURL;
	AVAsset *asset = [AVAsset assetWithURL:assetURL];
	AVPlayerItem *backgroundVideo = [AVPlayerItem playerItemWithAsset:asset];
	AVQueuePlayer *player = [[AVQueuePlayer alloc] init];
	AVPlayerLooper *looper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:backgroundVideo];

    player.muted = true;
    player.volume = 0;

    _playerView.playerLayer.affineTransform = model.transform;
    _playerView.player = player;

    _player = player;
    _looper = looper;

    _model = model;
}

-(void)viewDidLoad {
    UIView *view = self.view;
    _playerView = [[PlayerView alloc] init];
    [view addSubview:_playerView];
    
	view.clipsToBounds = true;
	view.userInteractionEnabled = true;
    _playerView.clipsToBounds = true;
    _playerView.translatesAutoresizingMaskIntoConstraints = false;

    _acceptButton = [[UILabel alloc] initWithFrame:CGRectZero];
	_declineButton = [[UILabel alloc] initWithFrame:CGRectZero];
    _callerLabel = [[JIFCallerLabel alloc] initWithFrame:CGRectZero];
    [view addSubview:_callerLabel];
	[view addSubview:_acceptButton];
	[view addSubview:_declineButton];

    _declineButton.translatesAutoresizingMaskIntoConstraints = false;
    _acceptButton.translatesAutoresizingMaskIntoConstraints = false;
    _callerLabel.translatesAutoresizingMaskIntoConstraints = false;

    _declineButton.backgroundColor = UIColor.darkGrayColor;
    _declineButton.text = @"Decline";
    _declineButton.textColor = UIColor.redColor;
    _declineButton.userInteractionEnabled = true;
    _declineButton.textAlignment = NSTextAlignmentCenter;

    _acceptButton.backgroundColor = UIColor.darkGrayColor;
    _acceptButton.text = @"Accept";
    _acceptButton.textColor = UIColor.greenColor;
    _acceptButton.userInteractionEnabled = true;
    _acceptButton.textAlignment = NSTextAlignmentCenter;

    UILabel *nameLabel = _callerLabel.nameLabel;
    nameLabel.textColor = UIColor.whiteColor;
    nameLabel.font = [UIFont systemFontOfSize:30];
    [nameLabel setMarqueeEnabled:true];
    [nameLabel setMarqueeRunning:true];

    UITapGestureRecognizer *acceptRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(acceptButtonDidTap)];
    [_acceptButton addGestureRecognizer:acceptRecognizer];
        
    UITapGestureRecognizer *declineRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(declineButtonDidTap)];
    [_declineButton addGestureRecognizer:declineRecognizer];

    UITapGestureRecognizer *expandRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandBanner)];
    [_playerView addGestureRecognizer:expandRecognizer];    

    [NSLayoutConstraint activateConstraints:@[
        [_playerView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [_playerView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [_callerLabel.topAnchor constraintEqualToAnchor:_playerView.topAnchor constant:10],
        [_callerLabel.centerXAnchor constraintEqualToAnchor:_playerView.centerXAnchor],
        [_callerLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:_playerView.leadingAnchor constant:8],
        [_callerLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_playerView.trailingAnchor constant:-8],
        [_acceptButton.topAnchor constraintEqualToAnchor:_playerView.bottomAnchor],
        [_acceptButton.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [_acceptButton.widthAnchor constraintEqualToConstant:buttonWidth],
        [_acceptButton.heightAnchor constraintEqualToConstant:buttonHeight],
        [_declineButton.topAnchor constraintEqualToAnchor:_playerView.bottomAnchor],
        [_declineButton.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [_declineButton.widthAnchor constraintEqualToConstant:buttonWidth],
        [_declineButton.heightAnchor constraintEqualToConstant:buttonHeight]
    ]];

    NSLayoutConstraint *labelBottomCnst = [_callerLabel.bottomAnchor constraintEqualToAnchor:_playerView.bottomAnchor constant:-10];
    labelBottomCnst.priority = 750;
    labelBottomCnst.active = true;

    NSLayoutConstraint *playerViewTopCnst = [_playerView.topAnchor constraintEqualToAnchor:view.topAnchor];
    playerViewTopCnst.priority = 749;
    playerViewTopCnst.active = true;

    NSLayoutConstraint *

    _expandedBannerConstraint = [_playerView.heightAnchor constraintEqualToAnchor:view.heightAnchor];
    _justOutsideWindowConstraint = [_acceptButton.bottomAnchor constraintEqualToAnchor:view.topAnchor];
    _justOutsideWindowConstraint.active = true;
}

-(void)expandBanner {
    self.view.alpha = 1;

    [self playBackgroundVideo];

    [UIView animateWithDuration:0.5 animations:^{
        _expandedBannerConstraint.active = true;
        _justOutsideWindowConstraint.active = false;
        [self.view layoutIfNeeded];
	} completion:^(BOOL finished){
    }];

    _isInBannerForm = false;
}

-(void)presentForLockscreen {
    UIView *view = self.view;
    view.alpha = 0;
    _callerLabel.alpha = 0;

    [self playBackgroundVideo];

    _expandedBannerConstraint.active = true;
    _justOutsideWindowConstraint.active = false;

    _isInBannerForm = false;

    [view layoutIfNeeded];

    [UIView animateWithDuration:0.5 animations:^{
       view.alpha = 1;
	} completion:nil];
}

-(void)retractBannerAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            _callerLabel.alpha = 1;
            _expandedBannerConstraint.active = false;
            [self.view layoutIfNeeded];
            log("VConstraints: %@", [_callerLabel constraints]);

	    } completion:nil];
    } else {
        _expandedBannerConstraint.active = false;
    }
    
    _isInBannerForm = true;
}

-(void)peekBanner {
    UIView *view = self.view;

    view.alpha = 1;

    [self playBackgroundVideo];

	[self retractBannerAnimated:false];

    _justOutsideWindowConstraint.active = true;

    [view layoutIfNeeded];

    [UIView animateWithDuration:0.5 animations:^{
        _justOutsideWindowConstraint.active = false;
        [view layoutIfNeeded];
	} completion:nil];

}

-(void)playBackgroundVideo {
    if (_player.rate > 0) {
        return;
    }

    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryAmbient error:nil]; // Don't know how this works but it is necessary to not interfere with ringtone
    [AVAudioSession.sharedInstance setActive:true error:nil];
    [_player play];
}

-(void)pauseBackgroundVideo {
    [_player pause];
    [AVAudioSession.sharedInstance setActive:false error:nil];
}

-(void)dismissBanner {
    UIView *view = self.view;

    bool isBanner = _isInBannerForm;

    [UIView animateWithDuration:0.5 animations:^{
        if (isBanner) {
            _justOutsideWindowConstraint.active = true;
            [view layoutIfNeeded];
        } else {
            view.alpha = 0;
        }
	} completion:^(BOOL completion) {
        [self pauseBackgroundVideo];

        self.view.window.hidden = true;
    }];
}

-(void)acceptButtonDidTap {
    [self.delegate bannerDidAccept];
}

-(void)updateForCall:(TUCall *)call {
    _callerLabel.nameLabel.text = [call displayName];
}

-(void)declineButtonDidTap {
    [self.delegate bannerDidDecline];
}
@end

@implementation PlayerView
- (AVPlayer *)player {
    return _playerLayer.player;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
        [self.layer addSublayer:_playerLayer];
        _playerLayer.frame = UIScreen.mainScreen.bounds;
    }
    return self;
}
 
- (void)setPlayer:(AVPlayer *)player {
    _playerLayer.player = player;
}
@end

@implementation JIFCallerLabel
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _blurBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self insertSubview:_blurBackgroundView atIndex:0];
        [self addSubview:_nameLabel];

        self.layer.cornerRadius = 5;

        [self addInitialConstraints];
        self.clipsToBounds = true;
        self.userInteractionEnabled = false;

        _nameLabel.translatesAutoresizingMaskIntoConstraints = false;

        _blurBackgroundView.frame = self.bounds;
        _blurBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(void)addInitialConstraints {
    UIView *label = _nameLabel;

    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:self.topAnchor constant:4],
        [label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4],
        [label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4],
        [label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10]
    ]];

    // super view doesn't have intrinsic content size 
    // so setting content hugging priority on super view doesn't work.
    // Only set content hugging priority on the view that HAS intrinsic content size.
    [label setContentHuggingPriority:900 forAxis:UILayoutConstraintAxisVertical];
}

@end