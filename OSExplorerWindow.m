#import "OSExplorerWindow.h"
#import "OSViewController.h"
#import "OSPaneModel.h"
#import "include.h"
#import "explorer/OSFileGridView.h"


#define desktopPane [[OSPaneModel sharedInstance] desktopPaneContainingWindow:self]
#define minHeight 200
#define minWidth 200

#define defaultDirectory @"/var/mobile/"

@implementation OSExplorerWindow
@synthesize fileGridView = _fileGridView;


- (id)init{
	if(![super initWithFrame:CGRectApplyAffineTransform([[UIScreen mainScreen] bounds], CGAffineTransformMakeScale(0.5, 0.5)) title:@"OS Explorer"])
		return nil;

	CGRect frame = self.frame;
	frame.origin.y = self.windowBar.bounds.size.height;

	self.fileGridView = [[OSFileGridView alloc] initWithDirectory:defaultDirectory frame:frame type:OSFileGridViewWindowed];
	self.fileGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.fileGridView.clipsToBounds = true;
	[self addSubview:self.fileGridView];
	[self sendSubviewToBack:self.fileGridView];

	self.backgroundColor = [UIColor whiteColor];

	return self;
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

- (void)dealloc{
	[self.fileGridView release];
	[super dealloc];
}


@end