#include "JIFRootListController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "JIFVideoEditViewController.h"
#import "Log.h"
#import "JIFPreferences.h"

@implementation JIFRootListController

- (NSArray *)specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
  }
  return _specifiers;
}


-(void)viewDidLoad {
  [super viewDidLoad];
  JIFPreferences *prefs = [JIFPreferences new];
  log("JIF %@", [prefs defaultJIF]);
}

- (void)chooseVideo {
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  picker.mediaTypes = @[ (NSObject *)kUTTypeMovie ];
  picker.delegate = self;
  picker.allowsEditing = true;
  [self presentViewController:picker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
      didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
  NSURL *trimmedAssetURL = info[UIImagePickerControllerMediaURL];
  JIFVideoEditViewController *editController = [[JIFVideoEditViewController alloc] initWithAssetURL:trimmedAssetURL];
  [picker dismissViewControllerAnimated:true completion:nil];
  [self presentViewController:editController animated:true completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
}

@end
