#import "OSViewController.h"




@implementation OSViewController
@synthesize slider = _slider;



-(void)loadView{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view.autoresizesSubviews = true;
	
	self.slider = [OSSlider sharedInstance];

	OSDesktopPane *desktopPane = [[OSDesktopPane alloc] init];
	[self.slider addPane:desktopPane];
	[self.slider addPane:[[OSDesktopPane alloc] init]];
	
	[self.view addSubview:self.slider];
}





-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return true;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
  
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
}



@end