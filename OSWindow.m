#import "OSWindow.h"
#import "OSViewController.h"


@implementation OSWindow
@synthesize windowBar = _windowBar;
@synthesize delegate = _delegate;
@synthesize resizeAnchor = _resizeAnchor;
@synthesize grabPoint = _grabPoint;
@synthesize grabPointInSuperview = _grabPointInSuperview;
@synthesize expandButton = _expandButton;
@synthesize originBeforeGesture = _originBeforeGesture;
@synthesize originInDesktop = _originInDesktop;
@synthesize desktopPaneOffset = _desktopPaneOffset;
@synthesize maxScale = _maxScale;


- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title{
	if(![super initWithFrame:arg1])
		return nil;

	self.layer.masksToBounds = false;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowRadius = 10;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;

	self.maxScale = 50;

	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, 0, self.frame.size.width, 40);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMCPanGesture:)];
	panGesture.maximumNumberOfTouches = 1;
	[panGesture requireGestureRecognizerToFail:[[OSSlider sharedInstance] switcherDownGesture]];
	[panGesture requireGestureRecognizerToFail:[[OSSlider sharedInstance] switcherUpGesture]];
	[self addGestureRecognizer:panGesture];
	[panGesture release];

	NSMutableArray *items = [[NSMutableArray alloc] init];

	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *titleLabel = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
	self.expandButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/167-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(expandButtonPressed)];
	UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	[items addObject:closeButton];
	[items addObject:flexibleSpace1];
	[items addObject:titleLabel];
	[items addObject:flexibleSpace2];
	[items addObject:self.expandButton];


	[self.windowBar setItems:items animated:false];
	[self addSubview:self.windowBar];


	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	[titleLabel.view addGestureRecognizer:panRecognizer];

	UIView *gestureBackdrop = [[UIView alloc] initWithFrame:self.windowBar.frame];
	gestureBackdrop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	gestureBackdrop.backgroundColor = [UIColor whiteColor];
	gestureBackdrop.alpha = 0.05;
	[self.windowBar addSubview:gestureBackdrop];
	[self.windowBar sendSubviewToBack:gestureBackdrop];
	[self.windowBar sendSubviewToBack:titleLabel.view];
	[self.windowBar sendSubviewToBack:self.windowBar._backgroundView];

	[gestureBackdrop addGestureRecognizer:panRecognizer];

	[panRecognizer release];

	UIPanGestureRecognizer *resizePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizePanGesture:)];
	[self.expandButton.view addGestureRecognizer:resizePanRecognizer];
	[resizePanRecognizer release];


	[title release];
	[closeButton release];
	[flexibleSpace1 release];
	[flexibleSpace2 release];
	[items release];

	return self;
}

- (void)handleMCPanGesture:(UIPanGestureRecognizer*)gesture{
	if(gesture.state == UIGestureRecognizerStateBegan){

		self.grabPoint = [gesture locationInView:self];
		self.grabPointInSuperview = [gesture locationInView:[self superview]];
		self.originBeforeGesture = self.frame.origin;

	}else if(gesture.state == UIGestureRecognizerStateChanged){
		[self updateTransform:[gesture locationInView:[self superview]]];

		CGRect frame = self.frame;

		CGPoint difference = CGPointSub([gesture locationInView:[self superview]], [self convertPoint:self.grabPoint toView:[self superview]]);
		frame.origin = CGPointAdd(difference, self.frame.origin);

		[self setFrame:frame];
	
	}else if(gesture.state == UIGestureRecognizerStateEnded){

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.maxScale * 0.01, self.maxScale * 0.01);
			CGRect frame = self.frame;
			frame.origin = self.originBeforeGesture;
			[self setFrame:frame];
		}completion:^(BOOL finished){
			
		}];
	}
}


- (void)updateTransform:(CGPoint)fingerPosition{
		const float max = self.grabPointInSuperview.y;
		const float percentage = fingerPosition.y / max;

		float transform = (((percentage * 100) * (self.maxScale - missionControlMinDragScale)) / 100) + missionControlMinDragScale;
		
		if(transform < missionControlMinDragScale){
			transform = missionControlMinDragScale;
		}else if(transform > self.maxScale){
			transform = self.maxScale;
		}

		transform = transform / 100;
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, transform, transform);
}

- (void)dealloc{
	[self.windowBar release];
	[self.expandButton release];
	[super dealloc];
}

- (void)layoutSubviews{
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture{
	[self.delegate window:self didRecievePanGesture:gesture];
}

- (void)stopButtonPressed{

}

- (void)expandButtonPressed{

}

- (void)handleResizePanGesture:(UIPanGestureRecognizer*)gesture{
	[self.delegate window:self didRecieveResizePanGesture:gesture];
}

- (CGRect) CGRectFromCGPoints:(CGPoint)p1 p2:(CGPoint)p2{
	return CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y));
}

@end