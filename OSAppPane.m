#import "OSAppPane.h"





@implementation OSAppPane
@synthesize application = _application;
@synthesize appView = _appView;
@synthesize windowBar = _windowBar;
@synthesize windowBarOpen = _windowBarOpen;
@synthesize windowBarShadowView = _windowBarShadowView;





-(id)initWithDisplayIdentifier:(NSString*)displayIdentifier{
	self.application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:displayIdentifier];


	if(![super initWithName:self.application.displayName thumbnail:nil]){
		return nil;
	}


	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];
	[self addSubview:self.appView];

	UIView *overlayView = [[UIView alloc] initWithFrame:self.frame];
	overlayView.alpha = 0.1;
	overlayView.backgroundColor = [UIColor grayColor];
	overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, -44, self.frame.size.width, 44);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.windowBar.hidden = true;
	NSMutableArray *items = [[NSMutableArray alloc] init];


	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.name style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *contractButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/168-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(contractButtonPressed)];

	[items addObject:closeButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:title];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:contractButton];



	[self.windowBar setItems:items animated:false];
	[items release];
	[self addSubview:self.windowBar];

	title.view.userInteractionEnabled = false;
	[title release];
	[closeButton release];
	[contractButton release];

	self.windowBarOpen = false;

	self.windowBarShadowView = [[UIView alloc] initWithFrame:self.frame];
	self.windowBarShadowView.backgroundColor = [UIColor blackColor];
	self.windowBarShadowView.alpha = 0.0;
	self.windowBarShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.windowBarShadowView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];

	[self addSubview:self.windowBarShadowView];
	[self bringSubviewToFront:self.windowBar];


	return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)gesture{
	[self setWindowBarHidden];
}

- (void)setWindowBarHidden{
	CGRect frame = [[self windowBar] frame];
	frame.origin.y = -frame.size.height;
		
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[[self windowBar] setFrame:frame];
		self.windowBarShadowView.alpha = 0.0;

	}completion:^(BOOL finished){
		[[self windowBar] setHidden:true];
	}];
		
	[self setWindowBarOpen:false];
	return;
}

- (void)setWindowBarVisible{
	[[self windowBar] setHidden:false];
	CGRect frame = [[self windowBar] frame];
	frame.origin.y = 0;
		
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[[self windowBar] setFrame:frame];
		self.windowBarShadowView.alpha = 0.5;
	}completion:^(BOOL finished){

	}];
		
	[self setWindowBarOpen:true];
}

- (void)dealloc{
	[self.windowBar release];
	[self.windowBarShadowView release];
	[super dealloc];
}

- (void)stopButtonPressed{
	[self.application suspend];
}




- (void)contractButtonPressed{

	CGAffineTransform appViewTransform = self.appView.transform;


	OSAppWindow *window = [[OSAppWindow alloc] initWithApplication:self.application];
	window.hidden = true;
	[[[OSPaneModel sharedInstance] firstDesktopPane] addSubview:window];
	[window setDelegate:[[OSPaneModel sharedInstance] firstDesktopPane]];



	[self addSubview:self.appView];
	self.appView.transform = appViewTransform;
	CGRect frame = self.appView.frame;
	frame.origin = CGPointZero;
	self.appView.frame = frame;


	CGPoint animationViewOrigin = [self convertPoint:self.appView.frame.origin toView:[[OSViewController sharedInstance] view]];
	[[[OSViewController sharedInstance] view] addSubview:self.appView];


	self.windowBar.autoresizingMask = UIViewAutoresizingNone;
	window.windowBar.autoresizingMask = UIViewAutoresizingNone;

	window.windowBar.frame = self.windowBar.frame;
  	[window.windowBar layoutSubviews];

	[[[OSViewController sharedInstance] view] addSubview:window.windowBar];
	[[[OSViewController sharedInstance] view] addSubview:self.windowBar];




	frame = self.appView.frame;
  	frame.origin = animationViewOrigin;
  	self.appView.frame = frame;

  	[UIView animateWithDuration:1.00 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

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


  		self.appView.transform = CGAffineTransformMakeRotation(DegreesToRadians(appViewDegrees));

  		if UIDeviceOrientationIsLandscape([self.application statusBarOrientation]){
			self.appView.transform = CGAffineTransformScale(self.appView.transform, (window.bounds.size.height - window.windowBar.bounds.size.height) / window.appView.bounds.size.width, window.bounds.size.width / window.appView.bounds.size.height);
		}else{
			self.appView.transform = CGAffineTransformScale(window.appView.transform, window.bounds.size.width / window.appView.bounds.size.width, (window.bounds.size.height - window.windowBar.bounds.size.height) / window.appView.bounds.size.height);
		}

		CGPoint origin = [self convertPoint:CGPointMake(window.frame.origin.x, window.frame.origin.y + window.windowBar.bounds.size.height) toView:[[OSViewController sharedInstance] view]];
		
		CGRect appFrame = self.appView.frame;
		appFrame.origin = origin;
		self.appView.frame = appFrame;

		
		window.windowBar.frame = CGRectMake(window.frame.origin.x, window.frame.origin.y, window.bounds.size.width, window.windowBar.bounds.size.height);

		self.windowBar.frame = window.windowBar.frame;
		self.windowBar.alpha = 0;

		[self.windowBar layoutSubviews];
		[window.windowBar layoutSubviews];

		//Scroll OSSlider
		CGRect bounds = [[OSSlider sharedInstance] bounds];
        bounds.origin.x = [[OSPaneModel sharedInstance] indexOfPane:[[OSPaneModel sharedInstance] firstDesktopPane]] * [[OSSlider sharedInstance] bounds].size.width;
        [[OSSlider sharedInstance] setBounds:bounds];
        [[OSSlider sharedInstance] updateDockPosition];
        [[OSThumbnailView sharedInstance] updateSelectedThumbnail];

  	}completion:^(BOOL finished){

  		CGRect appFrame = self.appView.frame;
  		appFrame.origin = CGPointMake(0, window.windowBar.bounds.size.height);
  		self.appView.frame = appFrame;

  		window.hidden = false;
  		[window addSubview:self.appView];
  		window.windowBar.frame = CGRectMake(0, 0, window.windowBar.bounds.size.width, window.windowBar.bounds.size.height);
  		[window addSubview:window.windowBar];

  		[self.windowBar removeFromSuperview];

		window.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		[[[OSPaneModel sharedInstance] firstDesktopPane] setActiveWindow:window];
		[[OSPaneModel sharedInstance] removePane:self];
		[window release];
  	}];


}











@end