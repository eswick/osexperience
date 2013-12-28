#import "OSFileGridTile.h"

@interface OSFileGridTileGhostView : OSFileGridTile

@property (assign) OSFileGridTile *tile;
@property (assign) CGPoint dragOffset;

- (id)initWithTile:(OSFileGridTile*)tile;

@end