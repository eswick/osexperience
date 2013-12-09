#import "OSFileGridViewController.h"
#import "OSFileViewController.h"
#import "OSFileGridTile.h"

#define tilesPerColumn self.bounds.size.height / self.gridSpacing.y
#define tilesPerRow self.bounds.size.width / self.gridSpacing.x

@implementation OSFileGridViewController
@synthesize type = _type;

- (id)init{
	if(![super init])
		return nil;

	self.type = OSFileGridViewTypeWindowed;
	self.tileSize = CGSizeMake(72, 72);
	self.gridSpacing = CGSizeMake(72, 72);

	return self;
}



- (void)loadView{
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//[self layoutView];
	self.loaded = true;
}

- (void)layoutView{
	for(UIView *view in self.view.subviews)
		[view removeFromSuperview];

	int index = 0;

	NSError *error = nil;

	for(NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.path includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error]){
		OSFileGridTile *tile = [self tileForFileAtPath:url];

		CGPoint origin = CGPointMake(self.view.bounds.size.width - (self.gridSpacing.width * (index + 1)), 0 + (self.gridSpacing.height * index));

		NSLog(@"Origin: %@", NSStringFromCGPoint(origin));
		
		CGRect frame = tile.frame;
		frame.origin = origin;
		tile.frame = frame;
	
		[self.view addSubview:tile];
		[tile release];

		index++;
	}
}

- (OSFileGridTile *)tileForFileAtPath:(NSURL*)path{
	OSFileGridTile *tile = [[OSFileGridTile alloc] initWithFrame:CGRectMake(0, 0, self.tileSize.width, self.tileSize.height)];

	UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:path];
	[tile setIcon:[[documentController icons] objectAtIndex:0]];

	//tile.backgroundColor = [UIColor greenColor];
	return tile;
}

@end