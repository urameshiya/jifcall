#import <Preferences/PSListController.h>
@import Photos;

@interface JIFRootListController : PSListController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@interface UIView (Private)
-(NSString *)recursiveDescription;
@end