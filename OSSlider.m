#import "OSSlider.h"


#define marginSize 40




@implementation OSSlider
@synthesize panes = _panes;
@synthesize startingOffset = _startingOffset;


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
	self.panGestureRecognizer.enabled = false;
	self.showsHorizontalScrollIndicator = false;


	self.panes = [NSMutableArray arrayWithCapacity:0];

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

-(void)layoutSubviews{

}



-(void)gestureBegan:(float)percentage{
	self.startingOffset = self.contentOffset;
}

-(void)gestureChanged:(float)percentage{

	[self setContentOffset:CGPointMake(self.startingOffset.x - ([UIScreen mainScreen].bounds.size.width * percentage), self.contentOffset.y) animated:false];
}

-(void)gestureCancelled{

	bool goingUp = false;
	
	if(fmod(self.contentOffset.x, self.frame.size.width) > self.frame.size.width / 2 || self.contentOffset.x < 0){
		goingUp = true;
	}

	if(self.contentOffset.x > self.contentSize.width - (self.frame.size.width / 2)){
		goingUp = false;
	}

	float xOffset = self.contentOffset.x;
	while((int)fmod(xOffset, self.frame.size.width) != 0){
		if(goingUp){
			xOffset++;
		}else{
			xOffset--;
		}
	}

	   [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [self setContentOffset:CGPointMake(xOffset, self.contentOffset.y)];
                     } 
                     completion:^(BOOL finished){
                     }];

	//[self _endPanWithEvent:nil];
}




@end