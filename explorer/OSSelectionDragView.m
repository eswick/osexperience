#import "OSSelectionDragView.h"



@implementation OSSelectionDragView

- (id)init{
	if(![super init])
		return nil;

	self.layer.borderColor = [UIColor whiteColor].CGColor;
	self.layer.borderWidth = 1.0f;
	self.alpha = 0.50f;
	self.userInteractionEnabled = false;

	self.whiteView = [[UIView alloc] initWithFrame:self.frame];
	self.whiteView.backgroundColor = [UIColor whiteColor];
	self.whiteView.alpha = 0.40;
	[self addSubview:self.whiteView];

	[self.whiteView release];

	return self;
}

- (void)layoutSubviews{
	self.whiteView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)dealloc{
	[self.whiteView release];
	[super dealloc];
}

@end