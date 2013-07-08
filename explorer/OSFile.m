#import "OSFile.h"




@implementation OSFile
@synthesize filename = _filename;
@synthesize path = _path;
@synthesize icon = _icon;
@synthesize isDirectory = _isDirectory;




-(id)initWithFile:(NSString *)file{
	if(![super init]){
		return nil;
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];


	BOOL isDir;

	if(![fileManager fileExistsAtPath:file isDirectory:&isDir]){
		return nil;
	}

	self.filename = [file lastPathComponent];
	self.path = [file stringByDeletingLastPathComponent];

	UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.absolutePath]];
	self.icon = [[documentController icons] objectAtIndex:0];


	return self;
}



-(NSString *)absolutePath{
	return [NSString stringWithFormat:@"%@/%@", self.path, self.filename];
}





@end




