#import "JIFSaver.h"
#import "Log.h"
#import "Paths.h"

@implementation JIFSaver

-(void)createLibraryFolderIfNeeded {
    [NSFileManager.defaultManager createDirectoryAtURL:[NSURL fileURLWithPath:JIFLibraryPath]
                                    withIntermediateDirectories:false
                                    attributes:nil
                                    error:nil];
}

-(void)overwriteMoveFileFromURL:(NSURL*)srcURL toURL:(NSURL*)destURL {
    NSError *error;
    [NSFileManager.defaultManager replaceItemAtURL:destURL
                                            withItemAtURL:srcURL
                                            backupItemName:nil
                                            options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                            resultingItemURL:nil
                                            error:&error];
    if (error) {
        log("JIFSaver encounters error while overwriting file.\nError: %@", error);
    } else {
        [NSFileManager.defaultManager removeItemAtURL:srcURL error:nil];
    }
}

-(NSURL *)persistJIFAtURL:(NSURL*)srcURL newName:(NSString*)name {
    [self createLibraryFolderIfNeeded];

    NSString *extension = srcURL.pathExtension.lowercaseString;
    NSArray *pathComponents = @[JIFLibraryPath, name];
    NSURL *destURL = [[NSURL fileURLWithPathComponents:pathComponents] URLByAppendingPathExtension:extension];

    [self overwriteMoveFileFromURL:srcURL toURL:destURL];
    return destURL;
}

@end