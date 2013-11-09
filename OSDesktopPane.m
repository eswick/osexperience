#import "OSDesktopPane.h"




@implementation OSDesktopPane
@synthesize wallpaperView = _wallpaperView;
@synthesize gridView = _gridView;
@synthesize statusBar = _statusBar;
@synthesize activeWindow = _activeWindow;
@synthesize windows = _windows;



-(id)init{
	if(![super initWithName:@"Desktop" thumbnail:nil]){
		return nil;
	}

	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.wallpaperView = [[objc_getClass("SBWallpaperView") alloc] initWithOrientation:[[UIApplication sharedApplication] statusBarOrientation] variant:1];
	self.wallpaperView.clipsToBounds = true;
	[self.wallpaperView setGradientAlpha:0.0];
	[self addSubview:self.wallpaperView];

	self.gridView = [[OSFileGridView alloc] initWithDirectory:@"/var/mobile/Desktop" frame:[[UIScreen mainScreen] applicationFrame]];
	[self addSubview:self.gridView];


	CGRect statusBarFrame = CGRectZero;
	statusBarFrame.size.width = self.bounds.size.width;
	statusBarFrame.size.height = 20;

	self.statusBar = [[objc_getClass("SBFakeStatusBarView") alloc] initWithFrame:statusBarFrame];
	self.statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.statusBar requestStyle:1];
	[self addSubview:self.statusBar];
	
	self.windows = [[NSMutableArray alloc] init];

	return self;
}

- (void)addSubview:(UIView*)arg1{
	[super addSubview:arg1];
	if([arg1 isKindOfClass:[OSWindow class]]){
		if(![self.windows containsObject:arg1])
			[self.windows addObject:arg1];
	}
}

- (BOOL)showsDock{
	return true;
}

- (OSWindow*)activeWindow{
	if(![self.subviews containsObject:_activeWindow])
		return nil;
	return _activeWindow;
}

- (void)window:(OSWindow*)window didRecievePanGesture:(UIPanGestureRecognizer*)gesture{
	if([[OSViewController sharedInstance] missionControlIsActive]){
		return;
	}

	if([gesture state] == UIGestureRecognizerStateBegan){
		[window setGrabPoint:[gesture locationInView:window]];
		[self bringSubviewToFront:window];
		[self setActiveWindow:window];
	}else if([gesture state] == UIGestureRecognizerStateChanged){
		CGRect frame = window.frame;
		frame.origin = CGPointSub([gesture locationInView:self], [window grabPoint]);
		if(frame.origin.y < self.statusBar.bounds.size.height)
			frame.origin.y = self.statusBar.bounds.size.height;
		window.frame = frame;
	}
}

- (void)window:(OSWindow*)window didRecieveResizePanGesture:(UIPanGestureRecognizer*)gesture{
	if([[OSViewController sharedInstance] missionControlIsActive]){
		return;
	}
	
	if([gesture state] == UIGestureRecognizerStateBegan){

		window.resizeAnchor = CGPointMake(window.frame.origin.x, window.frame.origin.y + window.frame.size.height);
		window.grabPoint = CGPointSub(CGPointMake(window.frame.size.width, 0), [gesture locationInView:window]);
	}else if([gesture state] == UIGestureRecognizerStateChanged){

		CGRect frame = [window CGRectFromCGPoints:window.resizeAnchor p2:CGPointAdd(window.grabPoint, [gesture locationInView:self])];

		if(frame.origin.y < self.statusBar.bounds.size.height){
			frame.origin.y = self.statusBar.bounds.size.height;
			frame.size = window.bounds.size;
		}

		window.frame = frame;
	}
}

- (void)missionControlWillActivate{
	for(OSWindow *window in self.subviews){
		if(![window isKindOfClass:[OSWindow class]])
			continue;
		[window setOriginInDesktop:window.frame.origin];
		window.windowBar.userInteractionEnabled = false;

		CGPoint origin = [self convertPoint:window.frame.origin toView:[OSSlider sharedInstance]];
		
		CGRect frame = window.frame;
		frame.origin = origin;
		window.frame = frame;

		window.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);

		[[OSSlider sharedInstance] addSubview:window];
	}
}

- (void)missionControlWillDeactivate{
	for(OSWindow *window in self.windows){
		if(![window isKindOfClass:[OSWindow class]])
			continue;
		
		window.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
		
		CGRect frame = window.frame;
		frame.origin = window.originInDesktop;
		[window setFrame:frame];
	}
}

- (void)missionControlDidDeactivate{
	for(OSWindow *window in self.windows){
		if(![window isKindOfClass:[OSWindow class]])
			continue;
		[self addSubview:window];
		window.windowBar.userInteractionEnabled = true;
	}
}

-(void)dealloc{
	[self.statusBar release];
	[self.wallpaperView release];
	[self.gridView release];
	[self.statusBar release];
	[self.windows release];

	[super dealloc];
}



@end