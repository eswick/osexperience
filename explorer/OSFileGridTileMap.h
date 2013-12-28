
@class OSFileGridTile;

@interface OSFileGridTileMap : NSObject

@property (retain) NSMutableDictionary *map;

- (int)indexOfTile:(OSFileGridTile*)tile;
- (void)addTile:(OSFileGridTile*)tile toIndex:(int)index;
- (void)removeTile:(OSFileGridTile*)tile;
- (OSFileGridTile*)tileWithURL:(NSURL*)url;

@end