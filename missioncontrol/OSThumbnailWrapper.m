#import "OSThumbnailWrapper.h"



@implementation OSThumbnailWrapper
@synthesize shouldAnimate = _shouldAnimate;


- (void)layoutSubviews{
	if(self.shouldAnimate){
		[self layoutSubviewsAnimated];
		return;
	}

	CGRect frame = CGRectZero;
	for(UIView *view in self.subviews){
		//NSLog(@"%@, %@", NSStringFromCGRect(frame), NSStringFromCGRect(view.frame));
		frame = CGRectUnion(frame, view.frame);
		//NSLog(@"%@", NSStringFromCGRect(frame));
	}
	[self setFrame:frame];
	
	CGPoint center = [[OSThumbnailView sharedInstance] center];
	center.y -= wrapperCenter;
	self.center = center;
}


- (void)layoutSubviewsAnimated{



	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^{

		CGRect frame = CGRectZero;

		for(UIView *view in self.subviews){
			NSLog(@"Frame: %@, View frame: %@", NSStringFromCGRect(frame), NSStringFromCGRect(view.frame));
			frame = CGRectUnion(frame, view.frame);
			NSLog(@"%@", view);
		}


		CGPoint center = [[OSThumbnailView sharedInstance] center];
		center.y -= wrapperCenter;

		frame.origin.x = center.x - (frame.size.width / 2);
		frame.origin.y = center.y - (frame.size.height / 2);

		[self setFrame:frame];



	}completion:^(BOOL finished){
		
	}];
}



@end