#import "OSFileViewController.h"

@implementation OSFileViewController

- (id)init{
	if(![super init])
		return nil;

	self.path = nil;
	self.view = nil;
	self.loaded = false;
	self.enumerationOptions = NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants;

	self.monitor = [FSMonitor new];
	self.monitor.delegate = self;
	[self.monitor release];

	return self;
}

- (void)loadView{

}

- (void)pathChanged{

}

- (void)layoutView{
	
}

- (void)setPath:(NSURL*)path{
	if(_path){
		[self.monitor removeDirectoryFilter:_path];
		[_path release];
	}

	_path = path;
	[_path retain];

	[self.monitor addDirectoryFilter:_path recursive:false];
	[self pathChanged];
}

- (void)monitor:(FSMonitor*)monitor recievedEventInfo:(NSDictionary*)info{
	NSLog(@"Not implemented.");
}

- (void)dealloc{
	[self.path release];
	[self.monitor release];
	[super dealloc];
}

@end