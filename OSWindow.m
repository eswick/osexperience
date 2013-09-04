#import "OSWindow.h"



@implementation OSWindow
@synthesize windowBar = _windowBar;
@synthesize delegate = _delegate;
@synthesize resizeAnchor = _resizeAnchor;
@synthesize grabPoint = _grabPoint;


- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title{
	if(![super initWithFrame:arg1])
		return nil;

	self.layer.masksToBounds = false;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowRadius = 10;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;


	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, 0, self.frame.size.width, 40);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	NSMutableArray *items = [[NSMutableArray alloc] init];

	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *titleLabel = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *expandButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/167-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(expandButtonPressed)];

	[items addObject:closeButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:titleLabel];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:expandButton];


	[self.windowBar setItems:items animated:false];
	[items release];
	[self addSubview:self.windowBar];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	[titleLabel.view addGestureRecognizer:panRecognizer];
	[panRecognizer release];

	UIPanGestureRecognizer *resizePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizePanGesture:)];
	[expandButton.view addGestureRecognizer:resizePanRecognizer];
	[resizePanRecognizer release];

	[title release];
	[closeButton release];
	[expandButton release];

	return self;
}

- (void)dealloc{
	[self.windowBar release];
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
	if([gesture state] == UIGestureRecognizerStateBegan){
		self.resizeAnchor = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
	}else if([gesture state] == UIGestureRecognizerStateChanged){
		self.frame = [self CGRectFromCGPoints:self.resizeAnchor p2:[gesture locationInView:[self superview]]];;
	}
}

- (CGRect) CGRectFromCGPoints:(CGPoint)p1 p2:(CGPoint)p2{
	return CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y));
}

@end