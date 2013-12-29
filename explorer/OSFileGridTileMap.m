#import "OSFileGridTileMap.h"
#import "OSFileGridTile.h"

#define URL_STD(url) [[url path] stringByStandardizingPath]

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
	NSMutableArray *array = [self arrayForTile:tile];
	int index = [self indexOfTile:tile];

	[[self arrayForTile:tile] removeObject:tile];
	
	if([array count] == 0)
		[self.map removeObjectForKey:@(index)];
}

- (OSFileGridTile*)tileWithURL:(NSURL*)url{
	for(NSString *key in self.map){
		NSMutableArray *array = [self.map objectForKey:key];
		for(OSFileGridTile *tile in array){
			if([URL_STD(tile.url) isEqualToString:URL_STD(url)])
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

- (int)firstEmptyIndex{
	int i = 0;
	while(true){
		if(![self.map objectForKey:@(i)])
			return i;
		i++;
	}
}

@end