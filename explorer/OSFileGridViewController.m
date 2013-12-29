#import "OSFileGridViewController.h"
#import "OSFileViewController.h"
#import "OSFileGridTile.h"
#import "OSSelectionDragView.h"
#import "OSFileGridTileGhostView.h"
#import "CGPointExtension.h"
#import "OSFileGridTileMap.h"
#import "OSFileGridTileLabel.h"
#import <libfsmonitor/libfsmonitor.h>
#import <math.h>

#define tilesPerColumn self.bounds.size.height / self.gridSpacing.y
#define tilesPerRow self.bounds.size.width / self.gridSpacing.x
#define metadataSubkey @"layout_grid"

#ifdef DEBUG
	#define metadataFileName @".OS_Store.plist"
#else
	#define metadataFileName @".OS_Store"
#endif

#define CGRectFromCGPoints(p1, p2) CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y))
#define URL_STD(url) [[url path] stringByStandardizingPath]


@implementation OSFileGridViewController
@synthesize type = _type;

- (id)init{
	if(![super init])
		return nil;

	self.type = OSFileGridViewTypeWindowed;
	self.iconSize = CGSizeMake(72, 72);
	self.gridSpacing = 20;

	self.tileMap = [[OSFileGridTileMap alloc] init];
	[self.tileMap release];
	
	return self;
}

- (void)loadView{
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.clipsToBounds = false;

	UIPanGestureRecognizer *selectGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectGesture:)];
	selectGesture.maximumNumberOfTouches = 1;
	[self.view addGestureRecognizer:selectGesture];
	[selectGesture release];

	self.loaded = true;

	[self.view release];

	for(NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.path includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]){
		OSFileGridTile *tile = [self tileForFileAtURL:url];

		tile.url = url;

		[self.tileMap addTile:tile toIndex:-1];
		[self.view addSubview:tile];
	}

	[self loadMetadata];

	NSArray *extraTiles = [NSArray arrayWithArray:[self.tileMap.map objectForKey:@(-1)]];
	for(OSFileGridTile *tile in extraTiles){
		[self.tileMap removeTile:tile];
		[tile removeFromSuperview];
	}
}

- (void)layoutView{
	NSError *error = nil;

	for(NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.path includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error]){
		
		OSFileGridTile *tile = [self.tileMap tileWithURL:url];

		CGPoint location;

		if(!tile){
			tile = [self tileForFileAtURL:url];

			tile.url = url;
			[self addTile:tile atIndex:[self.tileMap firstEmptyIndex]];
		}

		location = [self coordinatesOfTile:tile];

		CGPoint origin = CGPointMake(self.view.bounds.size.width - (tile.bounds.size.width * (location.x + 1)), 0 + (tile.bounds.size.height * location.y));

		CGRect frame = tile.frame;
		frame.origin = origin;
		tile.frame = frame;
	}
}

- (CGPoint)coordinatesOfTile:(OSFileGridTile*)tile{
	int index = [self.tileMap indexOfTile:tile];
	int iy = 0;
	int ix = 0;

	for(int i = 0; i < index; i++){
		if(tile.frame.size.height * (iy + 2) > self.view.bounds.size.height){
			ix++;
			iy = 0;
		}else{
			iy++;
		}
	}
	return CGPointMake(ix, iy);
}

- (void)addTile:(OSFileGridTile*)tile atIndex:(int)index{
	[self.tileMap addTile:tile toIndex:index];
	[self.view addSubview:tile];
	[self saveMetadata];
}

- (void)moveTile:(OSFileGridTile*)tile toIndex:(int)index{

	if([self.tileMap indexOfTile:tile] != -1){
		[self.tileMap removeTile:tile];
		[self.tileMap addTile:tile toIndex:index];
		[self layoutView];
	}

	[self saveMetadata];
}

- (void)deselectAll{
	for(OSFileGridTile *tile in self.view.subviews){
		if(![tile isKindOfClass:[OSFileGridTile class]])
			continue;
		[tile setSelected:false];
	}
}

- (void)handleSelectGesture:(UIPanGestureRecognizer *)gesture{
    if([gesture state] == UIGestureRecognizerStateChanged){

		[self.dragView setFrame:CGRectFromCGPoints(self.dragView.dragStartPoint, [gesture locationInView:self.view])];

		for(OSFileGridTile *tile in self.view.subviews){
			if(![tile isKindOfClass:[OSFileGridTile class]])
				continue;
			if(CGRectIntersectsRect(self.dragView.frame, tile.frame))
				[tile setSelected:true];
			else
				[tile setSelected:false];
		}
	}else if([gesture state] == UIGestureRecognizerStateBegan){

		self.dragView = [[OSSelectionDragView alloc] init];
		[self.view addSubview:self.dragView];
        [self.view bringSubviewToFront:self.dragView];
        self.dragView.hidden = false;
        self.dragView.dragStartPoint = [gesture locationInView:self.view];
        [self.dragView release];

	}else if([gesture state] == UIGestureRecognizerStateEnded || [gesture state] == UIGestureRecognizerStateCancelled){

		OSSelectionDragView *dragView = self.dragView;
		[dragView retain];

		self.dragView = nil;

        [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
			dragView.alpha = 0;
        }completion:^(BOOL finished){
        	[dragView release];
			[dragView removeFromSuperview];
        }];

    }
}

- (void)handleFileMoveGesture:(UIPanGestureRecognizer *)gesture{
	OSFileGridTile *tile = (OSFileGridTile*)[gesture view];

	if([gesture state] == UIGestureRecognizerStateBegan){
		if(!tile.selected){
			[self deselectAll];
			[tile setSelected:true];
		}

		tile.ghostView = [[OSFileGridTileGhostView alloc] initWithTile:tile];
		tile.ghostView.dragOffset = CGPointSub(tile.center, [gesture locationInView:self.view]);
		tile.ghostView.center = tile.center;

		[self.view addSubview:tile.ghostView];
		[self.view bringSubviewToFront:tile.ghostView];

		[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
			tile.ghostView.center = CGPointAdd(tile.ghostView.dragOffset, [gesture locationInView:self.view]);
		} completion:^(BOOL finished){ }];

	}else if([gesture state] == UIGestureRecognizerStateChanged){

		tile.ghostView.center = CGPointAdd(tile.ghostView.dragOffset, [gesture locationInView:self.view]);

	}else if([gesture state] == UIGestureRecognizerStateEnded){
		tile.center = tile.ghostView.center;
		[self.view bringSubviewToFront:tile];

		[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
			[self alignTileToGrid:tile];
		}completion:^(BOOL finished){ }];

		[tile.ghostView removeFromSuperview];
		[tile.ghostView release];
	}else if([gesture state] == UIGestureRecognizerStateCancelled){
		[tile.ghostView removeFromSuperview];
		[tile.ghostView release];
	}
}

- (void)alignTileToGrid:(OSFileGridTile*)tile{
	CGRect frame = tile.frame;

	if(frame.origin.x + frame.size.width > self.view.bounds.size.width)
		frame.origin.x = self.view.bounds.size.width - frame.size.width;
	else if(frame.origin.x < 0)
		frame.origin.x = fmod(self.view.bounds.size.width, frame.size.width);

	if(frame.origin.y + frame.size.height > self.view.bounds.size.height){
		frame.origin.y = (floorf(self.view.bounds.size.height / frame.size.height) - 1) * frame.size.height;
	}else if(frame.origin.y < 0)
		frame.origin.y = 0;

	float xmod = fmod(self.view.bounds.size.width - frame.origin.x, frame.size.width);
	float ymod = fmod(frame.origin.y, frame.size.height);

	if(xmod < frame.size.width / 2)
		frame.origin.x += xmod;
	else
		frame.origin.x -= frame.size.width - xmod;

	if(ymod < frame.size.height / 2)
		frame.origin.y -= ymod;
	else
		frame.origin.y += frame.size.height - ymod;

	int ix = ((self.view.bounds.size.width - frame.origin.x) / tile.frame.size.width) - 1;
	int iy = frame.origin.y / tile.frame.size.height;

	float maxY = floor(self.view.bounds.size.height / tile.frame.size.height);
	[self moveTile:tile toIndex:(ix * maxY) + iy];
}

- (void)monitor:(FSMonitor*)monitor recievedEventInfo:(NSDictionary*)info{
	FSMonitorEventType type = [[info objectForKey:@"TYPE"] intValue];

	switch(type){
		case FSMonitorEventTypeRename:
		{
			OSFileGridTile *tile = [self.tileMap tileWithURL:[info objectForKey:@"FILE"]];
			[tile setUrl:[info objectForKey:@"DEST_FILE"]];
			break;
		}
		case FSMonitorEventTypeDeletion:
		{
			OSFileGridTile *tile = [self.tileMap tileWithURL:[info objectForKey:@"FILE"]];
			[self.tileMap removeTile:tile];
			[tile removeFromSuperview];
			break;
		}
		case FSMonitorEventTypeFileCreation:
		case FSMonitorEventTypeDirectoryCreation:
			[self layoutView];
			break;
	}
}

- (void)saveMetadata{
	NSMutableDictionary *metadata = [NSMutableDictionary new];
	NSMutableDictionary *tileMetadata = [NSMutableDictionary new];

	for(NSNumber *key in self.tileMap.map){
		NSMutableArray *tileStack = [NSMutableArray new];
		for(OSFileGridTile *tile in [self.tileMap.map objectForKey:key]){
			[tileStack addObject:URL_STD(tile.url)];
		}
		[tileMetadata setObject:[NSArray arrayWithArray:tileStack] forKey:[key stringValue]];
		[tileStack release];
	}

	[metadata setObject:[NSDictionary dictionaryWithDictionary:tileMetadata] forKey:metadataSubkey];

	if(![[NSDictionary dictionaryWithDictionary:metadata] writeToFile:[URL_STD(self.path) stringByAppendingPathComponent:metadataFileName] atomically:true]){
		NSLog(@"Error saving metadata: %@", metadata);
	}

	[tileMetadata release];
	[metadata release];
}

- (void)loadMetadata{
	NSDictionary *metadata = [NSDictionary dictionaryWithContentsOfFile:[URL_STD(self.path) stringByAppendingPathComponent:metadataFileName]];
	NSDictionary *tileMetadata = [metadata objectForKey:metadataSubkey];

	if(!metadata || !tileMetadata)
		return;

	for(NSString *key in tileMetadata){
		NSArray *tileStack = [tileMetadata objectForKey:key];
		for(NSString *path in tileStack){
			OSFileGridTile *tile = [self.tileMap tileWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
			if(tile){
				[self.tileMap removeTile:tile];
				[self.tileMap addTile:tile toIndex:[key intValue]];
			}
		}
	}
}

- (OSFileGridTile *)tileForFileAtURL:(NSURL*)url{
	OSFileGridTile *tile = [[OSFileGridTile alloc] initWithIconSize:self.iconSize gridSpacing:self.gridSpacing];

	UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
	[tile setIcon:[[documentController icons] objectAtIndex:0]];

	UIPanGestureRecognizer *fileMoveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFileMoveGesture:)];
	[tile addGestureRecognizer:fileMoveGesture];
	[fileMoveGesture release];

	return [tile autorelease];
}

- (void)dealloc{
	[self.tileMap release];
	[self.view release];

	[super dealloc];
}

@end