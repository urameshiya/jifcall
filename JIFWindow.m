#import "JIFWindow.h"

@implementation JIFWindow
// - (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//     // Root view acts like a pass-through view...
// 	for (UIView *subview in self.rootViewController.view.subviews) {
//         if (!subview.hidden && subview.userInteractionEnabled 
//                 && [subview pointInside:[self convertPoint:point toView:subview] withEvent:event]) {
//             return true;
//         }
//     }
//     return false;
// }

// Root view acts as a pass-through view
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hit = [super hitTest:point withEvent:event];
    if (hit == self.rootViewController.view || hit == self) {
        return nil;
    }
    return hit;
}
@end