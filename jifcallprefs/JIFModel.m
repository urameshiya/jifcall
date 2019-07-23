#import "JIFModel.h"

@implementation JIFModel
-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[JIFModel class]]) {
        return false;
    }
    JIFModel *rhs = (JIFModel *)object;
    return self.videoURL ==  rhs.videoURL && CGAffineTransformEqualToTransform(self.transform, rhs.transform);
}
@end