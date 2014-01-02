#import "OSExplorerViewController.h"
#import "OSFileGridViewController.h"
#import "OSExplorerSidebarController.h"

#define sidebarWidth 150

@implementation OSExplorerViewController

- (id)init{
	if(![super init])
		return nil;

	self.fileViewController = [[OSFileGridViewController alloc] initWithPath:[NSURL URLWithString:@"/var/mobile"]];
	self.sidebarController = [[OSExplorerSidebarController alloc] init];

	[self.fileViewController release];
	[self.sidebarController release];
	return self;
}


- (void)loadView{
	self.view = [[UIView alloc] init];
 
	[self.view addSubview:self.sidebarController.view];
	[self.view addSubview:self.fileViewController.view];

	[self.view release];
}

- (void)viewDidLayoutSubviews{
	CGRect frame = self.sidebarController.view.frame;

	frame.origin = CGPointZero;
	frame.size.width = sidebarWidth;
	frame.size.height = self.view.bounds.size.height;
	self.sidebarController.view.frame = frame;

	frame = self.fileViewController.view.frame;
	frame.origin.x = self.sidebarController.view.frame.size.width;
	frame.origin.y = 0;
	frame.size.width = self.view.bounds.size.width - self.sidebarController.view.frame.size.width;
	frame.size.height = self.view.bounds.size.height;
	
	self.fileViewController.view.frame = frame;
}

- (void)dealloc{
	[self.fileViewController release];
	[self.sidebarController release];
	[super dealloc];
}

@end