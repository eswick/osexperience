#import "OSThumbnailWrapper.h"



@implementation OSThumbnailWrapper


- (void)layoutSubviews{
	CGRect frame;
	for(UIView *view in self.subviews){
		frame = CGRectUnion(frame, view.frame);
	}
	[self setFrame:frame];
	[[OSThumbnailView sharedInstance] alignWrapper];
}



@end