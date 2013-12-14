#import "OSFileGridTile.h"




@implementation OSFileGridTile

- (id)initWithIconSize:(CGSize)iconSize gridSpacing:(float)spacing{
	if(![super initWithFrame:CGRectMake(0, 0, iconSize.width + spacing, iconSize.height)])
		return nil;

	self.iconSize = iconSize;
	self.gridSpacing = spacing;


	CGRect iconViewFrame = CGRectMake(0, 0, self.iconSize.width, self.iconSize.height);

	self.iconView = [[UIImageView alloc] initWithFrame:iconViewFrame];
	[self addSubview:self.iconView];

	CGPoint center = self.iconView.center;
	center.x = self.bounds.size.width / 2;
	self.iconView.center = center;

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