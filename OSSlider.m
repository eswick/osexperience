#import "OSSlider.h"


#define marginSize 40




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
	self.panGestureRecognizer.minimumNumberOfTouches = 4;
	self.panGestureRecognizer.cancelsTouchesInView = false;
	self.showsHorizontalScrollIndicator = false;

	self.switcherUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwitcherGesture:)];
	self.switcherUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
	self.switcherUpGesture.numberOfTouchesRequired = 4;
	[self addGestureRecognizer:self.switcherUpGesture];

	self.switcherDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwitcherGesture:)];
	self.switcherDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
	self.switcherDownGesture.numberOfTouchesRequired = 4;
	[self addGestureRecognizer:self.switcherDownGesture];


	[self.panGestureRecognizer requireGestureRecognizerToFail:self.switcherUpGesture];
	[self.panGestureRecognizer requireGestureRecognizerToFail:self.switcherDownGesture];


	[self setDelegate:self];

	return self;
}


-(void)handleUpSwitcherGesture:(UISwipeGestureRecognizer *)gesture{
	if([[self currentPane] isKindOfClass:[OSAppPane class]]){
		if([(OSAppPane*)[self currentPane] windowBarIsOpen]){
			CGRect frame = [[(OSAppPane*)self.currentPane windowBar] frame];
			frame.origin.y = -frame.size.height;
		
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[[(OSAppPane*)self.currentPane windowBar] setFrame:frame];
			}completion:^(BOOL finished){
				[[(OSAppPane*)self.currentPane windowBar] setHidden:true];
			}];
		
			[(OSAppPane*)self.currentPane setWindowBarOpen:false];
			return;
		}
	}
	[[OSViewController sharedInstance] setMissionControlActive:true animated:true]; 
}

-(void)handleDownSwitcherGesture:(UISwipeGestureRecognizer *)gesture{
	if([[self currentPane] isKindOfClass:[OSAppPane class]] && ![[OSViewController sharedInstance] missionControlIsActive]){
		if(![(OSAppPane*)[self currentPane] windowBarIsOpen]){

			[[(OSAppPane*)self.currentPane windowBar] setHidden:false];
			CGRect frame = [[(OSAppPane*)self.currentPane windowBar] frame];
			frame.origin.y = 0;
		
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[[(OSAppPane*)self.currentPane windowBar] setFrame:frame];
			}completion:^(BOOL finished){
			}];
		
			[(OSAppPane*)self.currentPane setWindowBarOpen:true];
			return;
		}
	}

	[[OSViewController sharedInstance] setMissionControlActive:false animated:true]; 
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
 			[[(OSDesktopPane*)pane wallpaperView] setOrientation:orientation duration:duration];
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

	[self addSubview:pane];

	[self alignPanes];
}


- (void)removePane:(OSPane*)pane{
	OSPane *selectedPane = [self currentPane];

	if(selectedPane == pane){
		[self scrollToPane:[[OSPaneModel sharedInstance] paneAtIndex:0] animated:true];
		[pane removeFromSuperview];
		[self alignPanes];
		return;
	}

	[self scrollToPane:selectedPane animated:false];
	[pane removeFromSuperview];

}

-(void)alignPanes{
	self.contentSize = CGSizeMake([[OSPaneModel sharedInstance] count] * self.bounds.size.width, self.bounds.size.height);

	for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
		CGRect bounds = CGRectMake(0, 0, self.bounds.size.width - marginSize, self.bounds.size.height);
		pane.bounds = bounds;

		[pane setCenter:CGPointMake((self.bounds.size.width * [[OSPaneModel sharedInstance] indexOfPane:pane]) - (marginSize / 2) + (self.bounds.size.width / 2), pane.center.y)];
		
		pane.layer.shadowPath = [UIBezierPath bezierPathWithRect:pane.bounds].CGPath;
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
		[UIView animateWithDuration:1.0 delay:0.25 options: UIViewAnimationOptionCurveEaseInOut animations:^{
			CGRect bounds = [self bounds];
        	bounds.origin.x = [[OSPaneModel sharedInstance] indexOfPane:pane] * self.bounds.size.width;
        	[self setBounds:bounds];
        	[self updateDockPosition];
        	[[OSThumbnailView sharedInstance] updateSelectedThumbnail];

        }completion:^(BOOL finished){
         
        }];
	}
}


@end
















