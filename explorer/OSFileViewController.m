#import "OSFileViewController.h"

@implementation OSFileViewController

- (id)initWithPath:(NSURL*)path{
	if(![super init])
		return nil;

	self.path = path;

	return self;
}

- (void)dealloc{
	[self.path release];
	[super dealloc];
}

@end