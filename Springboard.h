#import "Frontboard.h"

@interface SBAlert: NSObject
-(void)setAlertDelegate:(id)arg;
-(bool)matchesAnyInCallService;
-(void)setFlag:(long long)flag forActivationSetting:(unsigned)setting;
-(void)setAlertManager:(id)arg1;
-(void)_setOccluding:(bool)arg1;
-(void)activate;
-(void)setWallpaperTunnelActive:(bool)arg;
@end

@interface SBAlertWindow: UIWindow
-(void)displayAlert:(SBAlert *)alert;
@end

@interface SBAlertManager
@property (nonatomic, retain) SBAlertWindow *alertWindow;
@property (nonatomic, retain) SBAlert *activeAlert;

-(void)_activate:(id)alert;
-(void)activate:(id)alert;
-(void)_createAlertWindowIfNecessaryForAlert:(id)alert;

// ADDED
-(void)jif_activate:(SBAlert *)alert;
-(NSMutableArray *)mutableAlerts;
@end

@interface SBWorkspaceAlert
@property (nonatomic,retain) SBAlert *alert; 
@end

@interface SBWorkspaceAlertTransitionContext
-(SBWorkspaceAlert *)alertToActivate;
@end

@interface SBWorkspaceTransitionRequest
-(SBWorkspaceAlertTransitionContext *)alertContext;
@end

@interface SBTransaction
-(void)addChildTransaction:(id)childTransaction;
@end

@interface SBAppsToAlertWorkspaceTransaction: SBTransaction
-(SBAlertManager *)alertManager;
-(void)_activateAlert;
-(void)_updateSceneLayout;

// ADDED
-(bool)activatingAlertMatchesAnyInCallService;
-(SBWorkspaceAlert *)activatingAlert;
@end

@interface SBAlertChangeTransaction: SBTransaction
-(id)initWithAlertManager:(id)arg1 toAlert:(id)arg2 ;

@end

@interface SBMainWorkspace
@property (nonatomic,readonly) SBAlertManager *alertManager;                                                                                                   //@synthesize alertManager=_alertManager - In the implementation block
+(instancetype)_instanceIfExists;
@end

@interface UIWindow (Private)
+(void)_synchronizeDrawing;
@end

@interface SBTelephonyManager
+(instancetype)sharedTelephonyManager;
-(bool)incomingCallExists;
@end

@interface SBAlertToAppsWorkspaceTransaction
@property (nonatomic,readonly) SBWorkspaceAlert * alert;
@end

@interface SBUIController
+(instancetype)sharedInstance;
-(BOOL)dissmissAlertItemsAndSheetsIfPossible;
@end

@interface SBSheetController
+(instancetype)sharedInstance;
-(BOOL)dismissAllSheets;
@end

@interface SBIconController
+(instancetype)sharedInstance;
-(void)handleHomeButtonTap;
@end