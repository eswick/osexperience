#import "OSSlider.h"


#define marginSize 40
#define scrollDuration 1.0
#define mcScrollDuration 0.40



@implementation OSSlider
@synthesize startingOffset = _startingOffset;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize currentPane = _currentPane;
@synthesize currentOrientation = _currentOrientation;
@synthesize pageIndexPlaceholder = _pageIndexPlaceholder;
@synthesize switcherUpGesture = _switcherUpGesture;
@synthesize switcherDownGesture = _switcherDownGesture;


+ (id)sharedInstance
{
    static OSSlider *_slider;

    if (_slider == nil)
    {
        _slider = [[self alloc] init];
    }

    return _slider;
}



-(id)init{
	CGRect frame = [[UIScreen mainScreen] bounds];
	frame.size.width += marginSize;

	if(![super initWithFrame:frame]){
		return nil;
	}

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pagingEnabled = true;
	self.clipsToBounds = false;
	self.showsHorizontalScrollIndicator = false;

	self.panGestureRecognizer.minimumNumberOfTouches = 4;
	self.panGestureRecognizer.cancelsTouchesInView = false;

	self.switcherUpGesture = [[OSSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwitcherGesture:)];
	self.switcherUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
	self.switcherUpGesture.numberOfTouchesRequired = 4;
	[self addGestureRecognizer:self.switcherUpGesture];

	self.switcherDownGesture = [[OSSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwitcherGesture:)];
	self.switcherDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
	self.switcherDownGesture.numberOfTouchesRequired = 4;
	[self addGestureRecognizer:self.switcherDownGesture];	

	[self.panGestureRecognizer requireGestureRecognizerToFail:self.switcherUpGesture];
	[self.panGestureRecognizer requireGestureRecognizerToFail:self.switcherDownGesture];


	[self setDelegate:self];

	[self.switcherUpGesture release];
	[self.switcherDownGesture release];

	return self;
}


-(void)handleUpSwitcherGesture:(UISwipeGestureRecognizer *)gesture{
	if([[self currentPane] isKindOfClass:[OSAppPane class]]){
		if([(OSAppPane*)[self currentPane] windowBarIsOpen]){
			[(OSAppPane*)[self currentPane] setWindowBarHidden];
			return;
		}
	}
	[[OSViewController sharedInstance] setMissionControlActive:true animated:true]; 
}

-(void)handleDownSwitcherGesture:(UISwipeGestureRecognizer *)gesture{
	if([[OSViewController sharedInstance] missionControlIsActive]){
		[[OSViewController sharedInstance] setMissionControlActive:false animated:true];
		return;
	}

	if([[self currentPane] isKindOfClass:[OSAppPane class]]){
		if(![(OSAppPane*)[self currentPane] windowBarIsOpen]){
			[(OSAppPane*)[self currentPane] setWindowBarVisible];
		}
	}
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{
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

}

-(void)addPane:(OSPane*)pane{

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
}


- (void)removePane:(OSPane*)pane{
	
	if([pane isKindOfClass:[OSDesktopPane class]]){
		for(OSWindow *window in [(OSDesktopPane*)pane windows]){

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
	}

	OSPane *destination = nil;
	
	if(pane != [self currentPane]){
		destination = [self currentPane];
	}else{
		for(OSDesktopPane *desktopPane in [[OSPaneModel sharedInstance] panes]){
			if(![desktopPane isKindOfClass:[OSDesktopPane class]] || desktopPane == pane)
				continue;
			destination = desktopPane;
		}
	}

	pane.hidden = true;

	[self scrollToPane:destination animated:true];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, mcScrollDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[pane removeFromSuperview];
		[self alignPanes];
		[[OSThumbnailView sharedInstance] updateSelectedThumbnail];
	});
	
}

-(void)alignPanes{
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



-(void)updateDockPosition{

	OSPane *intrudingPane;

	CGRect currentPaneRect = CGRectIntersection(self.currentPane.frame, self.bounds);

	CGRect intrudingPaneRect;

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

-(BOOL)isPortrait{
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }
    return false;
}

-(int)currentPageIndex{
	return nearbyint(self.contentOffset.x / self.bounds.size.width);
}

-(OSPane*)currentPane{
	return [[OSPaneModel sharedInstance] paneAtIndex:self.currentPageIndex];
}

- (void)scrollToPane:(OSPane*)pane animated:(BOOL)animated{
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

        	}completion:^(BOOL finished){}
        ];
	}
}

- (void)dealloc{
	[self.switcherUpGesture release];
	[self.switcherDownGesture release];

	[super dealloc];
}


@end
















