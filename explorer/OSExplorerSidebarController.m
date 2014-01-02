#import "OSExplorerSidebarController.h"


@implementation OSExplorerSidebarController

- (id)init{
	if(![super init])
		return nil;

	

	return self;
}

- (void)loadView{
	self.view = [[UIView alloc] init];

	self.view.backgroundColor = [UIColor redColor];

	[self.view release];
}

@end