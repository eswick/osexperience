#import "OSFileGridTile.h"




@implementation OSFileGridTile

- (id)initWithFrame:(CGRect)frame{
	if(![super initWithFrame:frame])
		return nil;

	CGRect iconViewFrame = frame;
	iconViewFrame.origin = CGPointZero;

	self.iconView = [[UIImageView alloc] initWithFrame:iconViewFrame];
	[self addSubview:self.iconView];

	return self;
}

- (void)setIcon:(UIImage*)icon{
	self.iconView.image = icon;
}

- (void)dealloc{
	[self.iconView release];
	[super dealloc];
}

@end