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
	self.iconSize = CGSizeMake(72, 72);
	self.gridSpacing = 20;

	return self;
}

- (void)loadView{
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.loaded = true;
}

- (void)layoutView{
	for(UIView *view in self.view.subviews)
		[view removeFromSuperview];

	int ix = 0;
	int iy = 0;

	NSError *error = nil;

	for(NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.path includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error]){
		if(self.iconSize.height * (iy + 1) > self.view.bounds.size.height){
			iy = 0;
			ix++;
		}

		OSFileGridTile *tile = [self tileForFileAtPath:url];

		CGPoint origin = CGPointMake(self.view.bounds.size.width - (tile.bounds.size.width * (ix + 1)), 0 + (tile.bounds.size.height * iy));

		CGRect frame = tile.frame;
		frame.origin = origin;
		tile.frame = frame;

		[self.view addSubview:tile];

		iy++;
	}
}

- (OSFileGridTile *)tileForFileAtPath:(NSURL*)path{
	OSFileGridTile *tile = [[OSFileGridTile alloc] initWithIconSize:self.iconSize gridSpacing:self.gridSpacing];

	UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:path];
	[tile setIcon:[[documentController icons] objectAtIndex:0]];

	return [tile autorelease];
}

@end