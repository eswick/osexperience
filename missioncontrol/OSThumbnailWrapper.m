#import "OSThumbnailWrapper.h"



@implementation OSThumbnailWrapper
@synthesize shouldLayoutSubviews = _shouldLayoutSubviews;


- (id)init{
	if(![super init])
		return nil;

	self.shouldLayoutSubviews = true;

	return self;
}

- (void)layoutSubviews{
	if(!self.shouldLayoutSubviews)
		return;
	else
		[self forceLayoutSubviews];
}



- (void)forceLayoutSubviews{

	CGRect frame = CGRectZero;

	for(UIView *view in self.subviews){
		frame = CGRectUnion(frame, view.frame);
	}

	CGPoint center = [[OSThumbnailView sharedInstance] center];
	center.y -= wrapperCenter;

	frame.origin.x = center.x - (frame.size.width / 2);
	frame.origin.y = center.y - (frame.size.height / 2);

	[self setFrame:frame];

}



@end