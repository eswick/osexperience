#import "OSSlider.h"


#define marginSize 40




@implementation OSSlider
@synthesize panes = _panes;
@synthesize startingOffset = _startingOffset;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize currentPane = _currentPane;


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


-(void)addPane:(OSPane*)pane{
	[self.panes addObject:pane];

	CGSize contentSize = self.contentSize;
	contentSize.width = (marginSize + pane.frame.size.width) * self.panes.count;

	[self setContentSize:contentSize];

	[pane setOriginX: (pane.frame.size.width + marginSize) * (self.panes.count - 1)];

	[self addSubview:pane];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateDockPosition];
}



-(void)updateDockPosition{
	OSPane *intrudingPane;
	CGRect currentPaneRect = CGRectIntersection([self convertRect:self.currentPane.frame toView:UIApplication.sharedApplication.keyWindow], self.frame);
	CGRect intrudingPaneRect;

	if(self.contentOffset.x >= self.currentPane.frame.origin.x){

		intrudingPane = [self paneAtIndex:self.currentPageIndex + 1];

	}else{

		intrudingPane = [self paneAtIndex:self.currentPageIndex - 1];
		
	}

	if(!intrudingPane)
		return;

	intrudingPaneRect = CGRectIntersection([self convertRect:intrudingPane.frame toView:UIApplication.sharedApplication.keyWindow], self.frame);

	float currentPanePercentage = (currentPaneRect.size.width * 100) / (self.frame.size.width - marginSize);
	float intrudingPanePercentage = (intrudingPaneRect.size.width * 100) / (self.frame.size.width - marginSize);


	float shownPercentage = 0;

	if(!self.currentPane.showsDock)
		shownPercentage += currentPanePercentage;

	if(!intrudingPane.showsDock)
		shownPercentage += intrudingPanePercentage;

	shownPercentage = shownPercentage * 0.01;

	CGRect dockFrame = [[[OSViewController sharedInstance] dock] frame];

	float dockShownY = [[OSViewController sharedInstance] view].frame.size.height - dockFrame.size.height;

	dockFrame.origin.y = dockShownY + (shownPercentage * dockFrame.size.height);

	[[[OSViewController sharedInstance] dock] setFrame:dockFrame];
}

-(int)currentPageIndex{
	return nearbyint(self.contentOffset.x / self.frame.size.width);
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