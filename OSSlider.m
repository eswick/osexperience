#import "OSSlider.h"


#define marginSize 40




@implementation OSSlider
@synthesize panes = _panes;


-(id)init{
	CGRect frame = [[UIScreen mainScreen] bounds];
	frame.size.width += marginSize;

	if(![super initWithFrame:frame]){
		return nil;
	}

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pagingEnabled = true;
	self.panGestureRecognizer.minimumNumberOfTouches = 4;
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



@end