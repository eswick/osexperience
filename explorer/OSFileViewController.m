#import "OSFileViewController.h"

@implementation OSFileViewController

- (id)initWithPath:(NSURL*)path{
	if(![super init])
		return nil;

	self.path = path;

	return self;
}

- (void)loadView{
	self.view = [[UIView alloc] init];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor greenColor];

	[self.view release];
}

- (void)dealloc{
	[self.path release];
	[self.view release];
	[super dealloc];
}

@end