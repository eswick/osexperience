#import "OSThumbnailView.h"
#import "OSThumbnailPlaceholder.h"
#import "OSPaneThumbnail.h"

@implementation OSThumbnailView
@synthesize wrapperView = _wrapperView;
@synthesize addDesktopButton = _addDesktopButton;
@synthesize shouldLayoutSubviews = _shouldLayoutSubviews;


+ (id)sharedInstance{
	static OSThumbnailView *_view;

	if (_view == nil)
	{
		_view = [[self alloc] init];
	}

	return _view;
}



- (id)init{



	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame.size.height = frame.size.height / 4;

	if(![super initWithFrame:frame])
		return nil;

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.hidden = true;


	self.wrapperView = [[OSThumbnailWrapper alloc] init];
	[self addSubview:self.wrapperView];

	self.addDesktopButton = [[OSAddDesktopButton alloc] init];
	self.addDesktopButton.delegate = self;

	CGPoint center = self.addDesktopButton.center;
	center.y = self.center.y;
	[self.addDesktopButton setCenter:center];
	[self addSubview:self.addDesktopButton];

	self.shouldLayoutSubviews = true;



	return self;
}

- (void)paneThumbnailTapped:(OSPaneThumbnail*)thumbnail{
	[[OSSlider sharedInstance] scrollToPane:[thumbnail pane] animated:true];
}

-(void)layoutSubviews{
	if(!self.shouldLayoutSubviews)
		return;
	else
		[self forceLayoutSubviews];
}

- (void)forceLayoutSubviews{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));

	CGPoint center = [self center];
	center.y -= wrapperCenter;

	if([[[OSPaneModel sharedInstance] panes] count] >= 5){
		frame.origin.x = self.frame.size.width;
		self.addDesktopButton.hidden = true;
	}else{
		frame.origin.x = [[UIScreen mainScreen] bounds].size.width - (frame.size.width / 2);
		if(![self isPortrait])
			frame.origin.x = [[UIScreen mainScreen] bounds].size.height - (frame.size.width / 2);
		self.addDesktopButton.hidden = false;
	}
	frame.origin.y = center.y - (frame.size.height / 2);

	[self.addDesktopButton setFrame:frame];
}

- (void)updateSelectedThumbnail{
	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		if(thumbnail.pane == [[OSSlider sharedInstance] currentPane])
			thumbnail.selected = true;
		else
			thumbnail.selected = false;
	}
}


-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{


	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame.size.height = frame.size.height / 4;

	[self setFrame:frame];

	[self alignSubviews];



}


- (void)alignSubviews{
	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		[thumbnail updateSize];
		thumbnail.layer.shadowPath = [UIBezierPath bezierPathWithRect:thumbnail.bounds].CGPath;
		thumbnail.frame = CGRectMake((thumbnail.frame.size.width + thumbnailMarginSize) * [[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane], 0, thumbnail.frame.size.width, thumbnail.frame.size.height);
	}

	CGPoint center = self.center;
	center.y -= wrapperCenter;
	self.wrapperView.center = center;


}



- (void)addPane:(OSPane*)pane{



	OSPaneThumbnail *thumbnail = [[OSPaneThumbnail alloc] initWithPane:pane];

	thumbnail.delegate = self;

	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbnailPanGesture:)];
	panGesture.maximumNumberOfTouches = 1;
	[thumbnail addGestureRecognizer:panGesture];


	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbnailLongPress:)];
	[thumbnail addGestureRecognizer:longPressRecognizer];
	[longPressRecognizer release];

	[self.wrapperView addSubview:thumbnail];
	[self alignSubviews];
	[self updateSelectedThumbnail];

	if([[OSViewController sharedInstance] missionControlIsActive])
		[thumbnail performSelector:@selector(prepareForDisplay) withObject:nil afterDelay:2.0];

	[panGesture release];
	[thumbnail release];


}

- (void)removePane:(OSPane*)pane animated:(BOOL)animated{


	OSPaneThumbnail *thumbnail;

	for(OSPaneThumbnail *view in self.wrapperView.subviews){
		if(view.pane == pane)
			thumbnail = view;
	}

	if(!thumbnail)
		return;

	if(animated){

		self.wrapperView.shouldLayoutSubviews = false;

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			thumbnail.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
		}completion:^(BOOL finished){

			[thumbnail removeFromSuperview];

			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				[self forceLayoutSubviews];
				[self alignSubviews];
				[self.wrapperView forceLayoutSubviews];
			}completion:^(BOOL finished){
				self.wrapperView.shouldLayoutSubviews = true;
			}];
		}];

	}else{
		[thumbnail removeFromSuperview];
		[self alignSubviews];
	}


}

- (void)handleThumbnailLongPress:(UILongPressGestureRecognizer *)gesture{

	if([gesture state] == UIGestureRecognizerStateBegan){
		for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
			if(![thumbnail isKindOfClass:[OSPaneThumbnail class]] || thumbnail == gesture.view)
				continue;
			if(thumbnail.closeboxVisible == true)
				[thumbnail setCloseboxVisible:false animated:true];
		}
		if(![(OSPaneThumbnail*)gesture.view closeboxVisible]){
			if([[(OSPaneThumbnail*)gesture.view pane] isKindOfClass:[OSDesktopPane class]]){
				if([[OSPaneModel sharedInstance] desktopPaneCount] <= 1){
					return;
				}
			}
			[(OSPaneThumbnail*)[gesture view] setCloseboxVisible:true animated:true];
		}
	}
}

- (void)closeAllCloseboxesAnimated:(BOOL)animated{
	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		if(![thumbnail isKindOfClass:[OSPaneThumbnail class]])
			continue;
		if(thumbnail.closeboxVisible == true)
			[thumbnail setCloseboxVisible:false animated:animated];
	}
}

-(void)handleThumbnailPanGesture:(UIPanGestureRecognizer *)gesture{

	if([gesture state] == UIGestureRecognizerStateChanged){

		CGRect frame = [[gesture view] frame];
		CGPoint result = CGPointSub([gesture locationInView:self], [(OSPaneThumbnail*)[gesture view] grabPoint]);
		frame.origin.x = result.x;
		frame.origin.y = self.wrapperView.frame.origin.y;
		[[gesture view] setFrame:frame];
		CGPoint pointInWrapper = [self convertPoint:gesture.view.frame.origin toView:self.wrapperView];

		for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
			if([[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane] > [[OSPaneModel sharedInstance] indexOfPane:[(OSPaneThumbnail*)[gesture view] pane]] && pointInWrapper.x > thumbnail.frame.origin.x){
				OSPane *selectedPane = [[OSSlider sharedInstance] currentPane];
				[[OSPaneModel sharedInstance] insertPane:[(OSPaneThumbnail*)[gesture view] pane] atIndex:[[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane]];
				[[OSSlider sharedInstance] scrollToPane:selectedPane animated:false];

				[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
					[self alignSubviews];
				}completion:^(BOOL finished){

				}];

			}else if([[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane] < [[OSPaneModel sharedInstance] indexOfPane:[(OSPaneThumbnail*)[gesture view] pane]] && pointInWrapper.x < thumbnail.frame.origin.x){

				OSPane *selectedPane = [[OSSlider sharedInstance] currentPane];
				[[OSPaneModel sharedInstance] insertPane:[(OSPaneThumbnail*)[gesture view] pane] atIndex:[[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane]];
				[[OSSlider sharedInstance] scrollToPane:selectedPane animated:false];

				[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
					[self alignSubviews];
				}completion:^(BOOL finished){

				}];
			}
		}


	}else if([gesture state] == UIGestureRecognizerStateBegan){

		gesture.view.alpha = 0.5;

		CGPoint grabPoint = [gesture locationInView:[gesture view]];
		[(OSPaneThumbnail*)[gesture view] setGrabPoint:grabPoint];


		OSThumbnailPlaceholder *placeholder = [(OSPaneThumbnail*)[gesture view] placeholder];

		[self.wrapperView addSubview:placeholder];

		[self addSubview:[gesture view]];

		CGRect frame = [[gesture view] frame];
		CGPoint result = CGPointSub([gesture locationInView:self], [(OSPaneThumbnail*)[gesture view] grabPoint]);
		frame.origin.x = result.x;
		frame.origin.y = self.wrapperView.frame.origin.y;
		[[gesture view] setFrame:frame];

		[self alignSubviews];
		[self.wrapperView layoutSubviews];

	}else if([gesture state] == UIGestureRecognizerStateEnded || [gesture state] == UIGestureRecognizerStateCancelled){

		CGRect frame = gesture.view.frame;
		frame.origin = [self convertPoint:frame.origin toView:self.wrapperView];
		[gesture.view setFrame:frame];

		[self.wrapperView addSubview:gesture.view];
		[[(OSPaneThumbnail*)[gesture view] placeholder] removeFromSuperview];

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			gesture.view.alpha = 1.0;
			[self alignSubviews];
		}completion:^(BOOL finished){

		}];
	}
}

- (void)addDesktopButtonWasTapped:(OSAddDesktopButton*)button{


	OSDesktopPane *desktop = [[OSDesktopPane alloc] init];

	[[OSPaneModel sharedInstance] addPaneToBack:desktop];

	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		if(![thumbnail isKindOfClass:[OSPaneThumbnail class]])
			continue;
		if(thumbnail.pane == desktop){
			thumbnail.placeholder.center = thumbnail.center;
			thumbnail.placeholder.hidden = true;

			self.wrapperView.shouldLayoutSubviews = false;

			[thumbnail removeFromSuperview];
			[self.wrapperView addSubview:[thumbnail placeholder]];
			[self alignSubviews];

			self.shouldLayoutSubviews = false;

			thumbnail.center = self.addDesktopButton.center;
			[self addSubview:thumbnail];
			[self bringSubviewToFront:self.addDesktopButton];

			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				[self.wrapperView forceLayoutSubviews];
			}completion:^(BOOL finished){

			}];

			[UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

				CGPoint center = [self.wrapperView convertPoint:thumbnail.placeholder.center toView:self];

				thumbnail.center = center;
				self.addDesktopButton.center = center;
				self.addDesktopButton.alpha = 0;

			}completion:^(BOOL finished){

				self.addDesktopButton.alpha = 1;

				CGRect frame = self.addDesktopButton.frame;
				frame.origin.x = self.frame.size.width;
				[self.addDesktopButton setFrame:frame];

				thumbnail.center = thumbnail.placeholder.center;
				[self.wrapperView addSubview:thumbnail];
				[thumbnail.placeholder removeFromSuperview];

				[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
					[self forceLayoutSubviews];
				}completion:^(BOOL finished){
					self.shouldLayoutSubviews = true;
					self.wrapperView.shouldLayoutSubviews = true;
				}];
			}];
		}
	}

	[desktop release];


}

- (BOOL)isPortrait:(UIInterfaceOrientation)orientation{
	if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
		return true;
	}
	return false;
}

- (BOOL)isPortrait{
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
		return true;
	}
	return false;
}

- (void)updatePressedThumbnails{
	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		if(![thumbnail.pane isKindOfClass:[OSDesktopPane class]])
			continue;
		BOOL pressed = false;

		for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
			if(![pane isKindOfClass:[OSDesktopPane class]])
				continue;
			for(OSWindow *window in pane.windows){
				if(![window isKindOfClass:[OSWindow class]] || [[(OSDesktopPane*)[thumbnail pane] windows] containsObject:window])
					continue;
				CGPoint originInThumbnailWrapper = [[window superview] convertPoint:window.frame.origin toView:self.wrapperView];

				CGRect rectInWrapper = window.frame;
				rectInWrapper.origin = originInThumbnailWrapper;

				CGRect intersection = CGRectIntersection(thumbnail.frame, rectInWrapper);

				if(CGRectIsNull(intersection)){
					continue;
				}

				if(intersection.size.width > rectInWrapper.size.width / 2 && intersection.size.height > rectInWrapper.size.height / 2){
					pressed = true;
				}
			}
		}

		if(pressed){
			thumbnail.pressed = true;
		}else{
			thumbnail.pressed = false;
		}
	}
}

- (OSPaneThumbnail*)thumbnailForPane:(OSPane*)pane{
	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		if(![thumbnail isKindOfClass:[OSPaneThumbnail class]])
			continue;
		if(thumbnail.pane == pane)
			return thumbnail;
	}
	return nil;
}


- (void)dealloc{
	[self.wrapperView release];
	[self.addDesktopButton release];
	[super dealloc];
}


@end
