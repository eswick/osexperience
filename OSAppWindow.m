#import "OSAppWindow.h"


@implementation OSAppWindow
@synthesize application = _application;
@synthesize appView = _appView;


- (id)initWithApplication:(SBApplication*)application{
	if(![super initWithFrame:CGRectMake(100, 100, 512, 384) title:application.displayName])
		return nil;

	self.clipsToBounds = true;

	self.application = application;


	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];

	CGRect frame = self.appView.frame;
	frame.origin.y += self.windowBar.bounds.size.height;
	
	self.appView.frame = frame;

	[self addSubview:self.appView];

	return self;
}


@end