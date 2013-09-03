#import "OSWindow.h"



@implementation OSWindow
@synthesize windowBar = _windowBar;
@synthesize delegate = _delegate;
@synthesize grabPoint = _grabPoint;


- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title{
	if(![super initWithFrame:arg1])
		return nil;



	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, 0, self.frame.size.width, 40);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	NSMutableArray *items = [[NSMutableArray alloc] init];

	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *titleLabel = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];

	[items addObject:closeButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:titleLabel];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];



	[self.windowBar setItems:items animated:false];
	[items release];
	[self addSubview:self.windowBar];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	[titleLabel.view addGestureRecognizer:panRecognizer];
	[panRecognizer release];

	[title release];
	[closeButton release];

	return self;
}


- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture{
	[self.delegate window:self didRecievePanGesture:gesture];
}

- (void)stopButtonPressed{

}


@end