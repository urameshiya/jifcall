@interface FBSSceneSettings
-(bool)isBackgrounded;
@end

@interface FBSMutableSceneSettings
-(void)setBackgrounded:(bool)arg;
@end

@interface FBScene
-(FBSSceneSettings *)settings;
-(void)updateSettingsWithBlock:(/*^block*/id)arg1 ;

@end
