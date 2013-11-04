#import "OSAppWindow.h"
#import "OSPaneModel.h"


@implementation OSAppWindow
@synthesize application = _application;
@synthesize appView = _appView;


- (id)initWithApplication:(SBApplication*)application{
	CGRect windowFrame = CGRectApplyAffineTransform([[UIScreen mainScreen] bounds], CGAffineTransformMakeScale(0.5, 0.5));

	if(UIInterfaceOrientationIsLandscape([application statusBarOrientation])){
		float width = windowFrame.size.width;
		windowFrame.size.width = windowFrame.size.height;
		windowFrame.size.height = width;
	}

	if(![super initWithFrame:windowFrame title:application.displayName])
		return nil;

	self.backgroundColor = [UIColor blackColor];

	windowFrame.size.height += self.windowBar.bounds.size.height;
	self.frame = windowFrame;

	if(UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation]))
		self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height / 2);
	else
		self.center = CGPointMake([[UIScreen mainScreen] bounds].size.height / 2, [[UIScreen mainScreen] bounds].size.width / 2);

	self.application = application;


	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];

	CGRect frame = self.appView.frame;
	frame.origin.y += self.windowBar.bounds.size.height;

	self.appView.frame = frame;
	[self addSubview:self.appView];

	UILongPressGestureRecognizer *rotateRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(expandButtonHeld:)];
	[self.expandButton.view addGestureRecognizer:rotateRecognizer];
	[rotateRecognizer release];


	return self;
}

- (void)applicationDidRotate{

	[self layoutSubviews];

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

		CGRect originalFrame = self.frame;
		CGRect frame = self.frame;

		if(frame.size.height < 200){
			frame.size.height = 200;
			frame.origin = originalFrame.origin;
		}

		if(UIDeviceOrientationIsPortrait([self.application statusBarOrientation])){
			frame.size.width = (UIScreen.mainScreen.bounds.size.width * (frame.size.height - self.windowBar.bounds.size.height)) / UIScreen.mainScreen.bounds.size.height;
		}else{
			frame.size.width = (UIScreen.mainScreen.bounds.size.height * (frame.size.height - self.windowBar.bounds.size.height)) / UIScreen.mainScreen.bounds.size.width;
		}

		self.frame = frame;

	}completion:^(BOOL finished){}];

}

- (void)expandButtonHeld:(UILongPressGestureRecognizer*)gesture{
	if([gesture state] == UIGestureRecognizerStateBegan){
		if(UIInterfaceOrientationIsPortrait([[self application] statusBarOrientation])){
			[[self application] rotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
		}else{
			[[self application] rotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
		}
	}
}

- (void)handleResizePanGesture:(UIPanGestureRecognizer*)gesture{

	if([gesture state] == UIGestureRecognizerStateBegan){
		self.resizeAnchor = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
	}else if([gesture state] == UIGestureRecognizerStateChanged){
		CGRect originalFrame = self.frame;

		[[self delegate] window:self didRecieveResizePanGesture:gesture];

		CGRect frame = self.frame;

		if(frame.size.height < 200){
			frame.size.height = 200;
			frame.origin = originalFrame.origin;
		}

		if (UIDeviceOrientationIsPortrait([self.application statusBarOrientation])){
			frame.size.width = (UIScreen.mainScreen.bounds.size.width * (frame.size.height - self.windowBar.bounds.size.height)) / UIScreen.mainScreen.bounds.size.height;
		}else{
			frame.size.width = (UIScreen.mainScreen.bounds.size.height * (frame.size.height - self.windowBar.bounds.size.height)) / UIScreen.mainScreen.bounds.size.width;
		}

		self.frame = frame;
	}

}

- (void)expandButtonPressed{
	[[self application] rotateToInterfaceOrientation:[UIApp statusBarOrientation]];
	
	CGAffineTransform appViewTransform = self.appView.transform;
  	OSAppPane *appPane = [[OSAppPane alloc] initWithDisplayIdentifier:[self.application bundleIdentifier]];
  	[self addSubview:self.appView];
  	self.appView.transform = appViewTransform;

  	CGPoint animationViewOrigin = [self convertPoint:self.appView.frame.origin toView:[[OSViewController sharedInstance] view]];
  	[[[OSViewController sharedInstance] view] addSubview:self.appView];

  	CGRect frame = self.appView.frame;
  	frame.origin = animationViewOrigin;
  	self.appView.frame = frame;

  	[[OSPaneModel sharedInstance] addPaneToBack:appPane];

  	self.windowBar.clipsToBounds = true;

  	frame = self.windowBar.frame;
  	frame.origin = [self convertPoint:self.windowBar.frame.origin toView:[[OSViewController sharedInstance] view]];
  	self.windowBar.frame = frame;
  	[self.windowBar layoutSubviews];
  	[[[OSViewController sharedInstance] view] addSubview:self.windowBar];

  	self.hidden = true;

  	[UIView animateWithDuration:1.00 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

  		int appViewDegrees;

		switch([UIApp statusBarOrientation]){
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

  		self.appView.transform = CGAffineTransformMakeRotation(DegreesToRadians(appViewDegrees));
		CGRect frame = self.appView.frame;
		frame.origin = CGPointMake(0, 0);
		self.appView.frame = frame;

		frame = self.windowBar.frame;
		frame.size.width = self.appView.frame.size.width;
		frame.origin.x = 0;
		frame.origin.y = -self.windowBar.frame.size.height;
		self.windowBar.frame = frame;
		[self.windowBar layoutSubviews];

		//Scroll OSSlider
		CGRect bounds = [[OSSlider sharedInstance] bounds];
        bounds.origin.x = [[OSPaneModel sharedInstance] indexOfPane:appPane] * [[OSSlider sharedInstance] bounds].size.width;
        [[OSSlider sharedInstance] setBounds:bounds];
        [[OSSlider sharedInstance] updateDockPosition];
        [[OSThumbnailView sharedInstance] updateSelectedThumbnail];

  	}completion:^(BOOL finished){
		[appPane addSubview:self.appView];
		[appPane sendSubviewToBack:self.appView];
		[appPane release];
		[self.windowBar removeFromSuperview];
		[[(OSDesktopPane*)[self superview] windows] removeObject:self];
		[self removeFromSuperview];
  	}];

}

- (void)layoutSubviews{
	[super layoutSubviews];

	if(![self.subviews containsObject:self.appView])
		return;

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

- (void)stopButtonPressed{
	[self.application suspend];
}


@end