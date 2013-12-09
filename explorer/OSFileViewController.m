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
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self layoutView];
	self.loaded = true;
	//self.view.backgroundColor = [UIColor greenColor];
}

- (void)pathChanged{

}

- (void)layoutView{
	
}

- (void)dealloc{
	[self.view release];
	[super dealloc];
}

@end