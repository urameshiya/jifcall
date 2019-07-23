@interface TUCall
-(NSString *)displayName;
@end

@interface TUCallCenter
@property (nonatomic,readonly) TUCall *incomingCall; 
@property (nonatomic,readonly) TUCall *incomingVideoCall; 
@property (nonatomic,readonly) TUCall *frontmostCall; 
+(instancetype)sharedInstance;
-(void)answerCall:(id)call;
-(void)disconnectCall:(id)arg1 withReason:(int)arg2;
@end