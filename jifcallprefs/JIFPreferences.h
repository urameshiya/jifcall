#import "JIFModel.h"
#import "Cephei/HBPreferences.h"

#define BUNDLE_ID @"zzz.canisitis.jifcall"

@interface JIFPreferences : NSObject

-(instancetype)init;

@property (nonatomic, assign, readonly) bool enabled;
@property (nonatomic, retain, readonly) JIFModel *defaultJIF;

-(void)setJIFAsDefault:(JIFModel *)model;

-(void)addCustomJIF:(JIFModel *)model forCallIdentifier:(NSString *)identifier;

@end