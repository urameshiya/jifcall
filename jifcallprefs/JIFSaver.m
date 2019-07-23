#import "JIFSaver.h"
#import "Log.h"
#import "Paths.h"

@implementation JIFSaver {
    NSURL *_finalURL;
    NSURL *_tempURL;
    NSFileManager *_fileManager;
}

-(instancetype)initWithDestinationURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _finalURL = url;
        _tempURL = [url URLByAppendingPathExtension:@"tmp"];
        _fileManager = NSFileManager.defaultManager;
    }

    return self;
}

-(void)cleanUpTemporaryFiles {
    [_fileManager removeItemAtURL:_tempURL error:nil];
}

-(void)finalizeFileWithError:(NSError * _Nullable *)error {
    [_fileManager replaceItemAtURL:_finalURL
                                            withItemAtURL:_tempURL
                                            backupItemName:nil
                                            options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                            resultingItemURL:nil
                                            error:error];
    // if (*error) {
    //     // TODO: Display error
    //     log("JIFSaver encounters error while overwriting file.\nError: %@", *error);
    // }
    [self cleanUpTemporaryFiles];
}

-(void)createLibraryFolderIfNeeded {
    [_fileManager createDirectoryAtURL:[NSURL fileURLWithPath:JIFLibraryPath]
                                    withIntermediateDirectories:false
                                    attributes:nil
                                    error:nil];
}

-(void)overwriteMoveFileFromURL:(NSURL*)srcURL toURL:(NSURL*)destURL {
    NSError *error;
    [_fileManager replaceItemAtURL:destURL
                                            withItemAtURL:srcURL
                                            backupItemName:nil
                                            options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                            resultingItemURL:nil
                                            error:&error];
    if (error) {
        log("JIFSaver encounters error while overwriting file.\nError: %@", error);
    } else {
        [_fileManager removeItemAtURL:srcURL error:nil];
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

-(void)dealloc {
    [self cleanUpTemporaryFiles];
}

+(NSURL *)urlForJIFNamed:(NSString *)name {
    NSArray *pathComponents = @[JIFLibraryPath, name];
    NSURL *destURL = [[NSURL fileURLWithPathComponents:pathComponents] URLByAppendingPathExtension:@"mov"];
    return destURL;
}
@end