#import "OSFileGridTileGhostView.h"


@implementation OSFileGridTileGhostView

- (id)initWithTile:(OSFileGridTile*)tile{
	if(![super initWithIconSize:tile.iconSize gridSpacing:tile.gridSpacing])
		return nil;

	self.tile = tile;

	self.url = tile.url;
	[self setIcon:self.tile.iconView.image];

	self.selectionBackdrop.backgroundColor = [UIColor clearColor];
	self.selectionBackdrop.layer.borderColor = [UIColor clearColor].CGColor;

	self.selected = true;
	self.alpha = 0.75;

	return self;
}

@end