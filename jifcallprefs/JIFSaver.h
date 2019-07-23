@interface JIFSaver : NSObject
+(NSURL *)urlForJIFNamed:(NSString *)name;

@property (nonatomic, readonly) NSURL *tempURL;
-(instancetype)initWithDestinationURL:(NSURL *)url;
-(void)overwriteMoveFileFromURL:(NSURL*)srcURL toURL:(NSURL*)destURL;
-(NSURL *)persistJIFAtURL:(NSURL*)srcURL newName:(NSString*)name;
-(void)finalizeFileWithError:(NSError * _Nullable *)error;
-(void)cleanUpTemporaryFiles;
@end