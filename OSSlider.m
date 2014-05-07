#import "OSSlider.h"
#import <mach_verify/mach_verify.h>
#import "OSPreferences.h"

#define marginSize [prefs PANE_SEPARATOR_SIZE]
#define scrollDuration [prefs SCROLL_TO_PANE_DURATION]
#define mcScrollDuration 0.40


@implementation OSSlider
@synthesize startingOffset = _startingOffset;
@synthesize currentOrientation = _currentOrientation;
@synthesize pageIndexPlaceholder = _pageIndexPlaceholder;


+ (id)sharedInstance
{
    static OSSlider *_slider;

    if (_slider == nil)
    {
        _slider = [[self alloc] init];
    }

    return _slider;
}

- (id)init{
	VERIFY_START(init);

	CGRect frame = [[UIScreen mainScreen] bounds];
	frame.size.width += marginSize;

	if(![super initWithFrame:frame]){
		return nil;
	}

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pagingEnabled = true;
	self.clipsToBounds = false;
	self.showsHorizontalScrollIndicator = false;

	self.backgroundColor = [UIColor blackColor];

	[self setDelegate:self];

	[self removeGestureRecognizer:self.panGestureRecognizer];
	
	VERIFY_STOP(init);

	return self;
}

- (void)handleUpSwitcherGesture:(UISwipeGestureRecognizer *)gesture{
	VERIFY_START(handleUpSwitcherGesture);

	if([[self currentPane] isKindOfClass:[OSAppPane class]]){
		if([(OSAppPane*)[self currentPane] windowBarIsOpen]){
			[(OSAppPane*)[self currentPane] setWindowBarHidden];
			return;
		}
	}
	[[OSViewController sharedInstance] setMissionControlActive:true animated:true]; 

	VERIFY_STOP(handleUpSwitcherGesture);
}

- (void)handleDownSwitcherGesture:(UISwipeGestureRecognizer *)gesture{
	VERIFY_START(handleDownSwitcherGesture);

	if([[OSViewController sharedInstance] missionControlIsActive]){
		[[OSViewController sharedInstance] setMissionControlActive:false animated:true];
		return;
	}

	if([[self currentPane] isKindOfClass:[OSAppPane class]]){
		if(![(OSAppPane*)[self currentPane] windowBarIsOpen]){
			[(OSAppPane*)[self currentPane] setWindowBarVisible];
		}
	}

	VERIFY_STOP(handleDownSwitcherGesture);
}

- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{
	VERIFY_START(willRotateToInterfaceOrientation$duration);

	int appViewDegrees;

	switch(orientation){
		case UIInterfaceOrientationPortrait:
			appViewDegrees = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			appViewDegrees = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			appViewDegrees = 90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			appViewDegrees = 270;
			break;
	}

 	for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){

 		if([pane isKindOfClass:[OSAppPane class]]){
 			UIView *appView = [(OSAppPane*)pane appView];
			appView.transform = CGAffineTransformMakeRotation(DegreesToRadians(appViewDegrees));
			CGRect frame = [appView frame];
			frame.origin = CGPointMake(0, 0);
			[appView setFrame:frame];
 		}else if([pane isKindOfClass:[OSDesktopPane class]]){
 			//[[(OSDesktopPane*)pane wallpaperView] setOrientation:orientation duration:duration];
 		}
 	}


 	[self alignPanes];
 	self.contentOffset = CGPointMake(self.pageIndexPlaceholder * self.bounds.size.width, 0);

 	[self updateDockPosition];


 	VERIFY_STOP(willRotateToInterfaceOrientation$duration);
}

- (void)addPane:(OSPane*)pane{

	VERIFY_START(addPane);

	CGSize contentSize = self.contentSize;
	contentSize.width = (marginSize + pane.frame.size.width) * [[OSPaneModel sharedInstance] count];

	[self setContentSize:contentSize];

	[pane setOriginX: (pane.frame.size.width + marginSize) * ([[OSPaneModel sharedInstance] count] - 1)];

	if([[OSViewController sharedInstance] missionControlIsActive])
		pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);

	if([[OSViewController sharedInstance] missionControlIsActive]){
		CGRect frame = [pane frame];
		frame.origin.y = 0;
		[pane setFrame:frame];
	}

	[self addSubview:pane];

	[self alignPanes];

	VERIFY_STOP(addPane);
}


- (void)removePane:(OSPane*)pane{
	VERIFY_START(removePane);
	
	if([pane isKindOfClass:[OSDesktopPane class]]){

		NSArray *windows = [[(OSDesktopPane*)pane windows] copy];

		for(OSWindow *window in windows){

			OSDesktopPane *toPane = nil;
			for(OSDesktopPane *desktopPane in [[OSPaneModel sharedInstance] panes]){
				if(![desktopPane isKindOfClass:[OSDesktopPane class]] || desktopPane == pane)
					continue;
				toPane = desktopPane;
				break;
			}

			CGRect frame = window.frame;
			frame.origin = [OSMCWindowLayoutManager convertPointFromSlider:frame.origin toPane:pane];
			frame.origin = [OSMCWindowLayoutManager convertPointToSlider:frame.origin fromPane:toPane];
			[window setFrame:frame];

			[window switchToDesktopPane:toPane];
			[self bringSubviewToFront:window];
		}

		[windows release];
	}

	OSPane *destination = nil;
	
	if(pane != [self currentPane]){
		destination = [self currentPane];
	}else{
		int index = [[[OSPaneModel sharedInstance] panes] indexOfObject:pane];
		if(index > 0){
			destination = [[OSPaneModel sharedInstance] paneAtIndex:index - 1];
		}else{
			destination = [[OSPaneModel sharedInstance] paneAtIndex:index + 1];
		}
	}

	pane.hidden = true;

	[self scrollToPane:destination animated:true];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, mcScrollDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[pane removeFromSuperview];
		[self alignPanes];
		[[OSThumbnailView sharedInstance] updateSelectedThumbnail];
	});
	
	VERIFY_STOP(removePane);
}

- (void)alignPanes{
	self.contentSize = CGSizeMake([[OSPaneModel sharedInstance] count] * self.bounds.size.width, self.bounds.size.height);

	for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
		[pane paneIndexWillChange];
		
		CGRect bounds = CGRectMake(0, 0, self.bounds.size.width - marginSize, self.bounds.size.height);
		pane.bounds = bounds;

		[pane setCenter:CGPointMake((self.bounds.size.width * [[OSPaneModel sharedInstance] indexOfPane:pane]) - (marginSize / 2) + (self.bounds.size.width / 2), pane.center.y)];
		
		pane.layer.shadowPath = [UIBezierPath bezierPathWithRect:pane.bounds].CGPath;

		[pane paneIndexDidChange];
	}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateDockPosition];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[[OSThumbnailView sharedInstance] updateSelectedThumbnail];
}



- (void)updateDockPosition{

	if([[objc_getClass("SBUIController") sharedInstance] scaleGestureInProgress]){
		return;
	}

	OSPane *intrudingPane;
	CGRect currentPaneRect = CGRectIntersection(self.currentPane.frame, self.bounds);
	CGRect intrudingPaneRect = CGRectZero;

	if(self.contentOffset.x >= self.currentPane.frame.origin.x){
		intrudingPane = [[OSPaneModel sharedInstance] paneAtIndex:self.currentPageIndex + 1];
	}else{
		intrudingPane = [[OSPaneModel sharedInstance] paneAtIndex:self.currentPageIndex - 1];
	}

	if(!intrudingPane && self.currentPane.showsDock){
		[[OSViewController sharedInstance] setDockPercentage:0.0];
		return;
	}else if(!intrudingPane && !self.currentPane.showsDock){
		[[OSViewController sharedInstance] setDockPercentage:1.0];
		return;
	}

	intrudingPaneRect = CGRectIntersection(intrudingPane.frame, self.bounds);

	float currentPanePercentage = (currentPaneRect.size.width * 100) / self.frame.size.width;
	float intrudingPanePercentage = (intrudingPaneRect.size.width * 100) / self.frame.size.width;
	
	float shownPercentage = 0;

	if(!self.currentPane.showsDock)
		shownPercentage += currentPanePercentage;

	if(!intrudingPane.showsDock)
		shownPercentage += intrudingPanePercentage;

	shownPercentage = shownPercentage * 0.01;

	[[OSViewController sharedInstance] setDockPercentage:shownPercentage];
}

- (BOOL)isPortrait{
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }
    return false;
}

- (int)currentPageIndex{
	return nearbyint(self.contentOffset.x / self.bounds.size.width);
}

- (OSPane*)currentPane{
	return [[OSPaneModel sharedInstance] paneAtIndex:self.currentPageIndex];
}

- (void)scrollToPane:(OSPane*)pane animated:(BOOL)animated{
	VERIFY_START(scrollToPane$animated);

	if(!animated){
		self.contentOffset = CGPointMake([[OSPaneModel sharedInstance] indexOfPane:pane] * self.bounds.size.width, 0);
		[self updateDockPosition];
		[[OSThumbnailView sharedInstance] updateSelectedThumbnail];
	}else{
		[UIView animateWithDuration:([[OSViewController sharedInstance] missionControlIsActive] ? mcScrollDuration : scrollDuration) 
			delay:([[OSViewController sharedInstance] missionControlIsActive] ? 0 : 0.25) 
			options: UIViewAnimationOptionCurveEaseInOut 
			animations:^{

				CGRect bounds = [self bounds];
        		bounds.origin.x = [[OSPaneModel sharedInstance] indexOfPane:pane] * self.bounds.size.width;
        		[self setBounds:bounds];
        		[self updateDockPosition];
        		[[OSThumbnailView sharedInstance] updateSelectedThumbnail];

        	}completion:^(BOOL completed){
        	}];
	}

	VERIFY_STOP(scrollToPane$animated);
}

- (void)beginPaging{
	self.pageOffsetBefore = self.contentOffset.x;
}

- (void)updatePaging:(float)percentage{

	CGPoint velocity = [self.swipeGestureRecognizer movementVelocityInPointsPerSecond];

	Ivar horizontalVelocity_ivar = class_getInstanceVariable(object_getClass(self), "_horizontalVelocity");
	Ivar previousHorizontalVelocity_ivar = class_getInstanceVariable(object_getClass(self), "_previousHorizontalVelocity");
	if (!horizontalVelocity_ivar || !previousHorizontalVelocity_ivar) return;

	double *horizontalVelocity = ((double*)((uint8_t*)self + ivar_getOffset(horizontalVelocity_ivar)));
	double *previousHorizontalVelocity = ((double*)((uint8_t*)self + ivar_getOffset(previousHorizontalVelocity_ivar)));
	
	*previousHorizontalVelocity = *horizontalVelocity;
	*horizontalVelocity = -(velocity.x / 300);

	float pageWidth = self.frame.size.width;

	float newContentOffset = 0;
	newContentOffset = (-percentage * pageWidth) + self.pageOffsetBefore;

#ifdef __LP64__ /* This doesn't seem to work on 32 bit devices. Crashes with a bus error. */
	BOOL outsideX;
	self.contentOffset = [self _rubberBandContentOffsetForOffset:CGPointMake(newContentOffset, self.contentOffset.y) outsideX:&outsideX outsideY:NULL];
#endif
	
}

- (void)swipeGestureEndedWithCompletionType:(long long)arg1 cumulativePercentage:(double)arg2{
	VERIFY_START(swipeGestureEndedWithCompletionType$cumulativePercentage);

	Ivar horizontalVelocity_ivar = class_getInstanceVariable(object_getClass(self), "_horizontalVelocity");
	if (!horizontalVelocity_ivar) return;
	double *horizontalVelocity = ((double*)((uint8_t*)self + ivar_getOffset(horizontalVelocity_ivar)));

	[self _prepareToPageWithHorizontalVelocity:*horizontalVelocity verticalVelocity:0];
	[self _endPanNormal:true];

	VERIFY_STOP(swipeGestureEndedWithCompletionType$cumulativePercentage);
}

- (void)dealloc{
	[super dealloc];
}


@end
















