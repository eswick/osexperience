#import "OSExplorerWindow.h"
#import "../OSViewController.h"
#import "../OSPaneModel.h"
#import "../include.h"


#define desktopPane [[OSPaneModel sharedInstance] desktopPaneContainingWindow:self]
#define minHeight 200
#define minWidth 200

#define defaultDirectory @"/var/mobile/"

@implementation OSExplorerWindow


- (id)init{
	CGRect frame = [[UIScreen mainScreen] bounds];
	
	if(UIInterfaceOrientationIsLandscape([UIApp statusBarOrientation])){
		float height = frame.size.height;
		frame.size.height = frame.size.width;
		frame.size.width = height;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(0.5, 0.5));

	if(![super initWithFrame:frame title:@"OS Explorer"])
		return nil;

	self.backgroundColor = [UIColor whiteColor];

	self.viewController = [[OSExplorerViewController alloc] init];
	[self.viewController loadView];

	frame = self.viewController.view.frame;
	frame.origin.x = 0; frame.origin.y = self.windowBar.frame.size.height;
	self.viewController.view.frame = frame;

	[self addSubview:self.viewController.view];

	[self.viewController release];

	return self;
}

- (void)layoutSubviews{
	[super layoutSubviews];

	CGRect frame = self.viewController.view.frame;

	frame.size.height = self.bounds.size.height - self.windowBar.frame.size.height;
	frame.size.width = self.bounds.size.width;

	self.viewController.view.frame = frame;
}


- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture{
	if([[OSViewController sharedInstance] missionControlIsActive]){
		return;
	}

	if([gesture state] == UIGestureRecognizerStateBegan){
		[self setGrabPoint:[gesture locationInView:self]];
		[desktopPane bringSubviewToFront:self];
		[desktopPane setActiveWindow:self];
	}else if([gesture state] == UIGestureRecognizerStateChanged){
		CGRect frame = self.frame;
		frame.origin = CGPointSub([gesture locationInView:desktopPane], [self grabPoint]);
		if(frame.origin.y < desktopPane.statusBar.bounds.size.height)
			frame.origin.y = desktopPane.statusBar.bounds.size.height;
		self.frame = frame;
	}
}

- (void)handleResizePanGesture:(UIPanGestureRecognizer*)gesture{

	if([gesture state] == UIGestureRecognizerStateBegan){
		[[self delegate] window:self didRecieveResizePanGesture:gesture];
	}else if([gesture state] == UIGestureRecognizerStateChanged){
		CGRect originalFrame = self.frame;

		[[self delegate] window:self didRecieveResizePanGesture:gesture];

		CGRect frame = self.frame;

		if(frame.size.height < minHeight){
			frame.size.height = minHeight;
			frame.origin = originalFrame.origin;
		}

		if(frame.size.width < minWidth){
			frame.size.width = minWidth;
			frame.origin = originalFrame.origin;
		}

		self.frame = frame;
	}
}

- (void)stopButtonPressed{
	[[[[OSPaneModel sharedInstance] desktopPaneContainingWindow:self] windows] removeObject:self];
	[self removeFromSuperview];
}

- (void)dealloc{
	[self.viewController release];
	[super dealloc];
}


@end