#import "JIFPreferences.h"

static JIFModel* parseJIF(NSDictionary *data);
static NSDictionary* serializeJIF(JIFModel *model);

@implementation JIFPreferences {
    HBPreferences *_prefs;
}

-(instancetype)init {
    _prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE_ID];
    return self;
}

-(bool)enabled {
    return [_prefs boolForKey:@"enabled" default:true];
}

-(JIFModel *)defaultJIF {
    NSDictionary *representation = [_prefs objectForKey:@"default"];
    return representation ? parseJIF(representation) : nil;
}

-(JIFModel *)customJIFForID:(NSString *)identifier {
    NSDictionary *customList = [_prefs objectForKey:@"custom"];
    if (!customList) {
        return nil;
    }
    NSDictionary *foundRepresentation = customList[identifier];
    
    return foundRepresentation ? parseJIF(foundRepresentation) : nil;
}

-(void)setJIFAsDefault:(JIFModel *)model {
    NSDictionary *representation = serializeJIF(model);
    [_prefs setObject:representation forKey:@"default"];
}

-(void)addCustomJIF:(JIFModel *)model forCallIdentifier:(NSString *)identifier {
    NSMutableDictionary *customList = [[_prefs objectForKey:@"custom" default:@{}] mutableCopy];
    customList[identifier] = serializeJIF(model);
    [_prefs setObject:customList forKey:@"custom"];
}

@end

static JIFModel* parseJIF(NSDictionary *data) {
    JIFModel *model = [JIFModel new];
    
    model.videoURL = [NSURL URLWithString:data[@"assetURL"]];
    model.transform = CGAffineTransformFromString(data[@"transform"]);

    return model;
}

static NSDictionary* serializeJIF(JIFModel *model) {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:2];

    dict[@"assetURL"] = model.videoURL.absoluteString;
    dict[@"transform"] = NSStringFromCGAffineTransform(model.transform);

    return dict;
}