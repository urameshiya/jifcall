#import "JIFBannerOverlay.h"

static CGFloat buttonRestingWidth = 70;
static CGFloat buttonMinWidth = 50;

@implementation JIFBannerOverlay {
    NSLayoutConstraint *_buttonWidthConstraint;
    NSLayoutConstraint *_minWidthConstraint;
}

-(instancetype)initWithDelegate:(id<JIFBannerOverlayDelegate>)delegate {
	self = [super initWithFrame:CGRectZero];
	if (self) {
        _delegate = delegate;
		_acceptButton = [[UIView alloc] initWithFrame:CGRectZero];
		_declineButton = [[UIView alloc] initWithFrame:CGRectZero];
        _callerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_callerLabel];
		[self addSubview:_acceptButton];
		[self addSubview:_declineButton];

        _declineButton.translatesAutoresizingMaskIntoConstraints = false;
        _acceptButton.translatesAutoresizingMaskIntoConstraints = false;
        _callerLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self updateInitialLayoutConstraints];

        _declineButton.backgroundColor = UIColor.redColor;
        _acceptButton.backgroundColor = UIColor.greenColor;
        [_callerLabel setMarqueeEnabled:true];
        [_callerLabel setMarqueeRunning:true];

        UITapGestureRecognizer *acceptRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(acceptButtonDidTap)];
        [_acceptButton addGestureRecognizer:acceptRecognizer];
        
        UITapGestureRecognizer *declineRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(declineButtonDidTap)];
        [_declineButton addGestureRecognizer:declineRecognizer];

        UITapGestureRecognizer *expandRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAreaDidTap)];
        [self addGestureRecognizer:expandRecognizer];

        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panRecognizer];
	}
	return self;
}

-(void)updateCallerLabelWithName:(NSString *)name {
    _callerLabel.text = name;
}

-(void)openAreaDidTap {
    [self retractButtonsThen:^{
        [_delegate bannerDidTapOnOpenArea];
    }];
}

-(void)retractButtonsThen:(void(^)(void))completion {
    _buttonWidthConstraint.constant = 0;
    _minWidthConstraint.active = false;

    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished){
        completion();
    }];
}

-(void)acceptButtonDidTap {
    [self retractButtonsThen:^{
        [_delegate bannerDidAccept];
    }];
}

-(void)declineButtonDidTap {
    [self retractButtonsThen:^{
        [_delegate bannerDidDecline];
    }];
}

-(void)handlePan:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
    // case UIGestureRecognizerStateBegan:
    //     break;
    case UIGestureRecognizerStateChanged: {
        _buttonWidthConstraint.constant -= [gesture translationInView:self].x / 2; // Divided by number of buttons
        [gesture setTranslation:CGPointZero inView:self];
        // [self setNeedsLayout:true]; // needed?
        [self layoutIfNeeded];
        break;
    }
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled: {
        [UIView animateWithDuration:0.2 animations:^{
            _buttonWidthConstraint.constant = buttonRestingWidth;
            [self layoutIfNeeded];
        } completion:nil];
        break;
    }
    default:
        break;
    }
}

-(void)animateIn {
    _buttonWidthConstraint.constant = buttonRestingWidth;
    _minWidthConstraint.active = true;
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

-(void)updateInitialLayoutConstraints {
    NSArray *oldConstraints = self.buttonLayoutConstraints;
    if (oldConstraints) {
        [NSLayoutConstraint deactivateConstraints:oldConstraints];
    }

    UIView *leftButton = _declineButton;
    UIView *rightButton = _acceptButton;
    UIView *callerLabel = _callerLabel;

    NSMutableArray *constraintsToActivate =  [NSMutableArray arrayWithObjects:
        [leftButton.trailingAnchor constraintEqualToAnchor:rightButton.leadingAnchor],
        [leftButton.topAnchor constraintEqualToAnchor:self.topAnchor],
        [leftButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [rightButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [rightButton.topAnchor constraintEqualToAnchor:self.topAnchor],
        [rightButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [rightButton.widthAnchor constraintEqualToAnchor:leftButton.widthAnchor],
        [callerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [callerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [callerLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [callerLabel.trailingAnchor constraintEqualToAnchor:leftButton.leadingAnchor constant:-8],
        nil
    ];

    NSLayoutConstraint *widthConstraint = [leftButton.widthAnchor constraintEqualToConstant:buttonRestingWidth];
    widthConstraint.priority = 750;
    [constraintsToActivate addObject:widthConstraint];

    NSLayoutConstraint *minWidthConstraint = [leftButton.widthAnchor constraintGreaterThanOrEqualToConstant:buttonMinWidth];
    [constraintsToActivate addObject:minWidthConstraint];

    [NSLayoutConstraint activateConstraints:constraintsToActivate];

    self.buttonLayoutConstraints = constraintsToActivate;
    _buttonWidthConstraint = widthConstraint;
    _minWidthConstraint = minWidthConstraint;
}
@end