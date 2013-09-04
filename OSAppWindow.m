#import "OSAppWindow.h"


@implementation OSAppWindow
@synthesize application = _application;
@synthesize appView = _appView;


- (id)initWithApplication:(SBApplication*)application{
	if(![super initWithFrame:CGRectMake(100, 100, 512, 384) title:application.displayName])
		return nil;


	self.application = application;


	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];

	CGRect frame = self.appView.frame;
	frame.origin.y += self.windowBar.bounds.size.height;

	self.appView.frame = frame;
	[self addSubview:self.appView];


	return self;
}

- (void)layoutSubviews{
	[super layoutSubviews];

	int appViewDegrees;

	switch([self.application statusBarOrientation]){
		case UIInterfaceOrientationPortrait:
			appViewDegrees = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			appViewDegrees = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			appViewDegrees = 90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			appViewDegrees = 270;
			break;
	}


	self.appView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians(appViewDegrees));

	if UIDeviceOrientationIsLandscape([self.application statusBarOrientation]){
		self.appView.transform = CGAffineTransformScale(self.appView.transform, (self.bounds.size.height - self.windowBar.bounds.size.height) / self.appView.bounds.size.width, self.bounds.size.width / self.appView.bounds.size.height);
	}else{
		self.appView.transform = CGAffineTransformScale(self.appView.transform, self.bounds.size.width / self.appView.bounds.size.width, (self.bounds.size.height - self.windowBar.bounds.size.height) / self.appView.bounds.size.height);
	}

	CGRect frame = self.appView.frame;
	frame.origin = CGPointZero;
	frame.origin.y += self.windowBar.bounds.size.height;
	self.appView.frame = frame;
}




@end