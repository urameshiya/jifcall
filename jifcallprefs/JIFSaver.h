@interface JIFSaver : NSObject

-(NSURL *)persistJIFAtURL:(NSURL*)srcURL newName:(NSString*)name;
@end