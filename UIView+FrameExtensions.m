#import "UIView+FrameExtensions.h"



@implementation UIView (FrameExtensions)





-(void)setOriginX:(float)origin{
	CGRect frame = [self frame];
	frame.origin.x = origin;
	[self setFrame:frame];
}

-(void)setOriginY:(float)origin{
	CGRect frame = [self frame];
	frame.origin.y = origin;
	[self setFrame:frame];
}

@end