#import "OSThumbnailWrapper.h"



@implementation OSThumbnailWrapper


- (void)layoutSubviews{
	CGRect frame;
	for(UIView *view in self.subviews){
		frame = CGRectUnion(frame, view.frame);
	}
	[self setFrame:frame];
	
	CGPoint center = [[OSThumbnailView sharedInstance] center];
	center.y -= wrapperCenter;
	self.center = center;
}



@end