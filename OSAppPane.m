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
	//self.clipsToBounds = true;


	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];
	[self addSubview:self.appView];



	UIView *overlayView = [[UIView alloc] initWithFrame:self.frame];
	overlayView.alpha = 0.1;
	overlayView.backgroundColor = [UIColor grayColor];
	overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	OSTouchForwarder *touchForwarder = [[OSTouchForwarder alloc] initWithApplication:self.application];
    [overlayView addGestureRecognizer:touchForwarder];

	[self addSubview:overlayView];

	[overlayView release];
	[touchForwarder release];

	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, -44, self.frame.size.width, 44);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.windowBar.hidden = true;
	NSMutableArray *items = [[NSMutableArray alloc] init];


	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.name style:UIBarButtonItemStylePlain target:nil action:nil];

	[items addObject:closeButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:title];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];



	[self.windowBar setItems:items animated:false];
	[items release];
	[self addSubview:self.windowBar];

	title.view.userInteractionEnabled = false;
	[title release];
	[closeButton release];

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



@end