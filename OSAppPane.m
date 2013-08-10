#import "OSAppPane.h"





@implementation OSAppPane
@synthesize application = _application;
@synthesize appView = _appView;
@synthesize windowBar = _windowBar;
@synthesize windowBarOpen = _windowBarOpen;





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

	return self;
}

- (void)dealloc{
	[self.windowBar release];
	[super dealloc];
}

- (void)stopButtonPressed{
	NSLog(@"Stop button pressed.");
}



@end