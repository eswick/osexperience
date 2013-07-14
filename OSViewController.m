#import "OSViewController.h"




@implementation OSViewController
@synthesize slider = _slider;
@synthesize dock = _dock;


+ (id)sharedInstance
{
    static OSViewController *_sharedController;

    if (_sharedController == nil)
    {
        _sharedController = [[self alloc] init];
    }

    return _sharedController;
}




-(void)loadView{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	



	//self.view.autoresizesSubviews = true;
	
	self.slider = [OSSlider sharedInstance];

	OSDesktopPane *desktopPane = [[OSDesktopPane alloc] init];
	[self.slider addPane:desktopPane];
	[self.slider addPane:[[OSDesktopPane alloc] init]];
	[self.view addSubview:self.slider];

	self.dock = [[objc_getClass("SBIconController") sharedInstance] dock];
	CGRect frame = self.dock.frame;
	frame.origin.y = [[UIScreen mainScreen] bounds].size.height - frame.size.height;
	[self.dock setFrame:frame];
	[self.view addSubview:self.dock];
	
	
}








-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return true;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
  
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
}



@end