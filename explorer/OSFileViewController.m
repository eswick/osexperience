#import "OSFileViewController.h"


@implementation OSFileViewController

- (id)init{
	if(![super init])
		return nil;

	self.path = nil;
	self.view = nil;
	self.loaded = false;
	self.enumerationOptions = NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants;

	return self;
}

- (void)loadView{

}

- (void)pathChanged{

}

- (void)layoutView{
	
}

- (void)dealloc{
	[self.path release];
	[super dealloc];
}

@end