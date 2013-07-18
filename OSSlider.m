#import "OSSlider.h"


#define marginSize 40




@implementation OSSlider
@synthesize panes = _panes;
@synthesize startingOffset = _startingOffset;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize currentPane = _currentPane;
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



	self.panes = [NSMutableArray arrayWithCapacity:0];

	[self setDelegate:self];

	return self;
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

 	for(OSPane *pane in self.panes){

 		if([pane isKindOfClass:[OSAppPane class]]){
 			UIView *appView = [(OSAppPane*)pane appView];
			appView.transform = CGAffineTransformMakeRotation(DegreesToRadians(appViewDegrees));
			CGRect frame = [appView frame];
			frame.origin = CGPointMake(0, 0);
			[appView setFrame:frame];
 		}
 	}


 	[self alignPanes];
 	self.contentOffset = CGPointMake(self.pageIndexPlaceholder * self.bounds.size.width, 0);

 	[self updateDockPosition];

}

-(void)addPane:(OSPane*)pane{
	[self.panes addObject:pane];

	CGSize contentSize = self.contentSize;
	contentSize.width = (marginSize + pane.frame.size.width) * self.panes.count;

	[self setContentSize:contentSize];

	[pane setOriginX: (pane.frame.size.width + marginSize) * (self.panes.count - 1)];

	[self addSubview:pane];

	[self alignPanes];
}

-(void)alignPanes{
	self.contentSize = CGSizeMake([self.panes count] * self.bounds.size.width, self.bounds.size.height);

	for(OSPane *pane in self.panes){
		pane.frame = CGRectMake([self.panes indexOfObject:pane] * self.bounds.size.width, 0, self.bounds.size.width - marginSize, self.bounds.size.height);
	}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateDockPosition];
}



-(void)updateDockPosition{

	BOOL isPortrait = self.isPortrait;




	OSPane *intrudingPane;
	CGRect currentPaneRect = CGRectIntersection([self convertRect:self.currentPane.frame toView:UIApplication.sharedApplication.keyWindow], self.frame);
	CGRect intrudingPaneRect;

	if(self.contentOffset.x >= self.currentPane.frame.origin.x){

		intrudingPane = [self paneAtIndex:self.currentPageIndex + 1];

	}else{

		intrudingPane = [self paneAtIndex:self.currentPageIndex - 1];
		
	}

	if(!intrudingPane && self.currentPane.showsDock){
		[[OSViewController sharedInstance] setDockPercentage:0.0];
		return;
	}else if(!intrudingPane && !self.currentPane.showsDock){
		[[OSViewController sharedInstance] setDockPercentage:1.0];
		return;
	}

	intrudingPaneRect = CGRectIntersection([self convertRect:intrudingPane.frame toView:UIApplication.sharedApplication.keyWindow], self.frame);


	float currentPanePercentage = ((isPortrait ? currentPaneRect.size.width : currentPaneRect.size.height) * 100) / ((isPortrait ? self.frame.size.width : self.frame.size.height) - marginSize);
	float intrudingPanePercentage = ((isPortrait ? intrudingPaneRect.size.width : intrudingPaneRect.size.height) * 100) / ((isPortrait ? self.frame.size.width : self.frame.size.height) - marginSize);


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
	//return nearbyint(self.contentOffset.x / (self.isPortrait ? self.bounds.size.width : self.bounds.size.height));
}

-(OSPane*)currentPane{
	return [self paneAtIndex:self.currentPageIndex];
}

-(OSPane*)paneAtIndex:(int)index{
	if(index < 0 || index > self.panes.count - 1)
		return nil;
	return [self.panes objectAtIndex:index];
}

/*-(void)setContentOffset:(CGPoint)arg1{
	[super setContentOffset:arg1];
	NSLog(@"Set content offset!");
}*/


@end