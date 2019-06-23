
@protocol JIFBannerOverlayDelegate
-(void)bannerDidTapOnOpenArea;
-(void)bannerDidAccept;
-(void)bannerDidDecline;
@end

@interface JIFBannerOverlay: UIView
@property (nonatomic, retain) NSArray *buttonLayoutConstraints;
@property (nonatomic, retain) UIView *acceptButton;
@property (nonatomic, retain) UIView *declineButton;
@property (nonatomic, weak) id<JIFBannerOverlayDelegate> delegate;

-(instancetype)initWithDelegate:(id<JIFBannerOverlayDelegate>)delegate;
-(void)animateIn;
-(void)retractButtons;
@end
