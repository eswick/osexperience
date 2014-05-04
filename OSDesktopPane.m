#import "OSDesktopPane.h"
#import "missioncontrol/OSMCWindowLayoutManager.h"
#import <mach_verify/mach_verify.h>
#import "OSPreferences.h"

#define snapMargin [prefs SNAP_MARGIN]

@implementation OSDesktopPane
@synthesize wallpaperView = _wallpaperView;
@synthesize statusBar = _statusBar;
@synthesize activeWindow = _activeWindow;
@synthesize windows = _windows;


-(id)init{
	VERIFY_START(OSDesktopPane$init);
	if(![super initWithName:@"Desktop" thumbnail:nil]){
		return nil;
	}

	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.wallpaperController = [[objc_getClass("SBWallpaperController") alloc] initWithOrientation:[UIApp statusBarOrientation] variant:0];
	self.wallpaperView = [self.wallpaperController _wallpaperViewForVariant:0];
	self.wallpaperView.clipsToBounds = true;
	self.wallpaperView.frame = self.bounds;

	[self addSubview:self.wallpaperView];
	[self.wallpaperController release];

	CGRect statusBarFrame = CGRectZero;
	statusBarFrame.size.width = self.bounds.size.width;
	statusBarFrame.size.height = 20;

	self.statusBar = [[objc_getClass("SBFakeStatusBarView") alloc] initWithFrame:statusBarFrame];
	self.statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.statusBar requestStyle:1];
	[self addSubview:self.statusBar];
	
	self.windows = [[NSMutableArray alloc] init];

	[self.statusBar release];
	[self.windows release];

	self.showingRightSnapIndicator = false;

	self.snapIndicator = [[UIView alloc] init];
	self.snapIndicator.backgroundColor = [UIColor grayColor];
	self.snapIndicator.alpha = 0.5;
	self.snapIndicator.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.snapIndicator.layer.borderWidth = 1;
	self.snapIndicator.hidden = true;
	[self addSubview:self.snapIndicator];
	[self.snapIndicator release];

	VERIFY_STOP(OSDesktopPane$init);

	return self;
}

- (BOOL)showsDock{
	return [[OSViewController sharedInstance] desktopShowsDock];
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

		/* Bounds checking */
		if(frame.origin.y < self.statusBar.bounds.size.height)
			frame.origin.y = self.statusBar.bounds.size.height;
		if(frame.origin.x + (frame.size.width / 2) < 0)
			frame.origin.x = -(frame.size.width / 2);
		if(frame.origin.x + (frame.size.width / 2) > self.bounds.size.width)
			frame.origin.x = self.bounds.size.width - (frame.size.width / 2);
		if(frame.origin.y + window.windowBar.frame.size.height > self.bounds.size.height)
			frame.origin.y = self.bounds.size.height - window.windowBar.frame.size.height;

		window.frame = frame;

		if(![window isKindOfClass:[OSAppWindow class]])
			return;

		if([gesture locationInView:self].x > self.bounds.size.width - snapMargin){ //Right side of screen
			if(UIInterfaceOrientationIsLandscape([UIApp statusBarOrientation])){
				if(!UIInterfaceOrientationIsPortrait([[(OSAppWindow*)window application] statusBarOrientation])){
					[[(OSAppWindow*)window application] rotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
					return;
				}
				if(!self.showingRightSnapIndicator){
					[self insertSubview:self.snapIndicator belowSubview:window];
					[self setRightSnapIndicatorVisible:true animated:true];
				}
			}
		}else if([gesture locationInView:self].x < snapMargin){
			if(UIInterfaceOrientationIsLandscape([UIApp statusBarOrientation])){
				if(!UIInterfaceOrientationIsPortrait([[(OSAppWindow*)window application] statusBarOrientation])){
					[[(OSAppWindow*)window application] rotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
					return;
				}
				if(!self.showingLeftSnapIndicator){
					[self insertSubview:self.snapIndicator belowSubview:window];
					[self setLeftSnapIndicatorVisible:true animated:true];
				}
			}
		}else{
			if(self.showingRightSnapIndicator)
				[self setRightSnapIndicatorVisible:false animated:true];
			else if(self.showingLeftSnapIndicator)
				[self setLeftSnapIndicatorVisible:false animated:true];
		}
	}else if([gesture state] == UIGestureRecognizerStateEnded){
		if(![window isKindOfClass:[OSAppWindow class]])
			return;

		if(self.showingRightSnapIndicator){
			OSAppWindow *appWindow = (OSAppWindow*)window;

			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:^{
					appWindow.frame = self.snapIndicator.frame;
				}
				completion:nil
			];

			[self setRightSnapIndicatorVisible:false animated:true];
		}else if(self.showingLeftSnapIndicator){
			OSAppWindow *appWindow = (OSAppWindow*)window;

			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:^{
					appWindow.frame = self.snapIndicator.frame;
				}
				completion:nil
			];

			[self setLeftSnapIndicatorVisible:false animated:true];
		}
	}
}

- (void)setRightSnapIndicatorVisible:(BOOL)visible animated:(BOOL)animated{
	VERIFY_START(setRightSnapIndicatorVisible$animated);
	self.showingRightSnapIndicator = visible;

	if(visible){
		self.snapIndicator.hidden = false;
		self.snapIndicator.frame = CGRectMake(self.bounds.size.width, self.bounds.size.height / 2, 0, 0);

		void (^snapToFrame)(void) = ^{
			self.snapIndicator.frame = CGRectMake(self.bounds.size.width / 2, self.statusBar.frame.size.height, self.bounds.size.width / 2, self.bounds.size.height - self.statusBar.frame.size.height);
		};

		if(animated){
			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:snapToFrame
				completion:nil
			];
		}else{
			snapToFrame();
		}
	}else{

		if(animated){
			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:^{
					self.snapIndicator.alpha = 0;
				}
				completion:^(BOOL finished){
					self.snapIndicator.alpha = 0.5;
					self.snapIndicator.hidden = true;
				}];
		}else{
			self.snapIndicator.hidden = true;
		}
	}

	VERIFY_STOP(setRightSnapIndicatorVisible$animated);
}

- (void)setLeftSnapIndicatorVisible:(BOOL)visible animated:(BOOL)animated{
	VERIFY_START(setLeftSnapIndicatorVisible$animated);

	self.showingLeftSnapIndicator = visible;

	if(visible){
		self.snapIndicator.hidden = false;
		self.snapIndicator.frame = CGRectMake(0, self.bounds.size.height / 2, 0, 0);

		void (^snapToFrame)(void) = ^{
			self.snapIndicator.frame = CGRectMake(0, self.statusBar.frame.size.height, self.bounds.size.width / 2, self.bounds.size.height - self.statusBar.frame.size.height);
		};

		if(animated){
			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:snapToFrame
				completion:nil
			];
		}else{
			snapToFrame();
		}
	}else{

		if(animated){
			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:^{
					self.snapIndicator.alpha = 0;
				}
				completion:^(BOOL finished){
					self.snapIndicator.alpha = 0.5;
					self.snapIndicator.hidden = true;
				}];
		}else{
			self.snapIndicator.hidden = true;
		}
	}

	VERIFY_STOP(setLeftSnapIndicatorVisible$animated);
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
	VERIFY_START(missionControlWillActivate);

	for(OSWindow *window in self.subviews){
		if(![window isKindOfClass:[OSWindow class]])
			continue;
		[window setOriginInDesktop:window.frame.origin];
		window.windowBar.userInteractionEnabled = false;

		CGRect frame = [OSMCWindowLayoutManager convertRectToSlider:window.frame fromPane:self];
		window.frame = frame;

		[[OSSlider sharedInstance] addSubview:window];
	}

	VERIFY_STOP(missionControlWillActivate);
}

- (void)missionControlWillDeactivate{
	VERIFY_START(missionControlWillDeactivate);

	for(OSWindow *window in self.windows){
		if(![window isKindOfClass:[OSWindow class]])
			continue;
		
		window.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
		
		CGRect frame = window.frame;
		frame.origin = [self convertPoint:window.originInDesktop toView:[self superview]];
		[window setFrame:frame];
	}

	VERIFY_STOP(missionControlWillDeactivate);
}

- (void)missionControlDidDeactivate{
	VERIFY_START(missionControlDidDeactivate);

	for(OSWindow *window in self.windows){
		if(![window isKindOfClass:[OSWindow class]])
			continue;

		CGRect frame = window.frame;
		frame.origin = window.originInDesktop;
		[window setFrame:frame];

		[self addSubview:window];
		window.windowBar.userInteractionEnabled = true;
	}

	VERIFY_STOP(missionControlDidDeactivate);
}

- (void)paneIndexWillChange{
	VERIFY_START(paneIndexWillChange);

	for(OSWindow *window in self.windows){
		if(![window isKindOfClass:[OSWindow class]])
			continue;
		window.desktopPaneOffset = CGPointSub(window.frame.origin, self.frame.origin);
	}

	VERIFY_STOP(paneIndexWillChange);
}

- (void)layoutSubviews{
	self.wallpaperView.frame = self.bounds;
}

- (void)paneIndexDidChange{
	VERIFY_START(paneIndexDidChange);

	[self setName:[NSString stringWithFormat:@"Desktop %i", [self desktopPaneIndex]]];

	for(OSWindow *window in self.windows){
		if(![window isKindOfClass:[OSWindow class]] || [[self subviews] containsObject:window])
			continue;
		CGPoint newOffset = CGPointSub(window.frame.origin, self.frame.origin);

		CGPoint difference = CGPointSub(window.desktopPaneOffset, newOffset);

		CGRect frame = window.frame;
		frame.origin = CGPointAdd(difference, frame.origin);

		[window setFrame:frame];
	}

	VERIFY_STOP(paneIndexDidChange);
}

- (int)desktopPaneIndex{
	int count = 0;
	for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSDesktopPane class]])
			continue;
		count++;
		if(pane == self)
			break;
	}
	return count;
}

-(void)dealloc{
	[self.wallpaperController release];
	[self.statusBar release];
	[self.windows release];
	[self.snapIndicator release];

	[super dealloc];
}



@end