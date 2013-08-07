#import "OSAppPane.h"





@implementation OSAppPane
@synthesize application = _application;
@synthesize appView = _appView;
@synthesize windowBar = _windowBar;





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
	self.windowBar.frame = CGRectMake(0, 0, self.frame.size.width, 44);
	NSMutableArray *items = [[NSMutableArray alloc] init];


	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.name style:UIBarButtonItemStylePlain target:nil action:nil];

	[items addObject:closeButton];
	[items addObject:title];
	[items addObject:spacer];



	[self.windowBar setItems:items animated:false];
	[items release];
	[self addSubview:self.windowBar];

	title.view.userInteractionEnabled = false;
	[title release];
	[closeButton release];
	[spacer release];

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