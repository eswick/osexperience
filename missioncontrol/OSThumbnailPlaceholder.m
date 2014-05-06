#import "OSThumbnailPlaceholder.h"
#import "OSThumbnailView.h"



@implementation OSThumbnailPlaceholder



- (id)initWithPane:(OSPane*)pane{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![[OSThumbnailView sharedInstance] isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));

	if(![super initWithFrame:frame])
		return nil;

	self.pane = pane;

	self.hidden = true;
	self.userInteractionEnabled = false;

	return self;
}



- (void)updateImage{
	return;
}

- (void)updateLabel{
	return;
}


@end