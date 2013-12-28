#import "OSFileGridTileMap.h"
#import "OSFileGridTile.h"


@implementation OSFileGridTileMap

- (id)init{
	if(![super init])
		return nil;

	self.map = [[NSMutableDictionary alloc] init];

	return self;
}

- (int)indexOfTile:(OSFileGridTile*)tile{
	for(NSNumber *key in self.map){
		NSMutableArray *array = [self.map objectForKey:key];
		if([array containsObject:tile])
			return [key intValue];
	}

	return -1;
}

- (void)addTile:(OSFileGridTile*)tile toIndex:(int)index{
	if([self containsTile:tile]){
		NSLog(@"Tile already added!");
		return;
	}

	if(![self.map objectForKey:[NSNumber numberWithInt:index]]){
		[self.map setObject:[NSMutableArray arrayWithCapacity:1] forKey:[NSNumber numberWithInt:index]];
	}

	[[self.map objectForKey:[NSNumber numberWithInt:index]] addObject:tile];
}

- (void)removeTile:(OSFileGridTile*)tile{
	[[self arrayForTile:tile] removeObject:tile];
}

- (OSFileGridTile*)tileWithURL:(NSURL*)url{
	for(NSString *key in self.map){
		NSMutableArray *array = [self.map objectForKey:key];
		for(OSFileGridTile *tile in array){
			if([[tile.url path] isEqualToString:url.path])
				return tile;
		}
	}
	return nil;
}

- (BOOL)containsTile:(OSFileGridTile*)tile{
	for(NSString *key in self.map){
		NSMutableArray *array = [self.map objectForKey:key];
		if([array containsObject:tile])
			return true;
	}

	return false;
}

- (NSMutableArray*)arrayForTile:(OSFileGridTile*)tile{
	for(NSString *key in self.map){
		NSMutableArray *array = [self.map objectForKey:key];
		if([array containsObject:tile])
			return array;
	}
	return nil;
}

@end