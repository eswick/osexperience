#import "OSFileGridViewController.h"
#import "OSSelectionDragView.h"
#import "CGPointExtension.h"
#import "OSFileGridTile.h"
#import <icns.h>

#define CGRectFromCGPoints(p1, p2) CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y))
#define URL_STD(url) [[url path] stringByStandardizingPath]

@implementation OSFileGridViewController

- (id)initWithPath:(NSURL*)path{
	if(![super initWithPath:path])
		return nil;

	self.iconSize = CGSizeMake(72, 72);
	self.gridSpacing = 20;

	return self;
}


- (void)loadView{
	self.view = [[UIView alloc] init];

	UIPanGestureRecognizer *selectGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectGesture:)];
	selectGesture.maximumNumberOfTouches = 1;
	[self.view addGestureRecognizer:selectGesture];
	[selectGesture release];

	self.view.backgroundColor = [UIColor whiteColor];

	[self updateTiles];

	[self.view release];
}

- (void)viewDidLayoutSubviews{
	for(OSFileGridTile *tile in self.tiles){
		int index = [self.tiles indexOfObject:tile];

		float x = 0, y = 0; 

		for(int i = 0; i < index; i++){
			if(tile.frame.size.width * (i + 1) > self.view.bounds.size.width){
				x = 0;
				y++;
				continue;
			}
			x++;
		}
		NSLog(@"Index: %i, x: %f, y: %f", index, x, y);
		CGRect frame = tile.frame;
		frame.origin = CGPointMake(x * tile.frame.size.width, y + tile.frame.size.width);

		tile.frame = frame;
	}
}

- (void)handleSelectGesture:(UIPanGestureRecognizer *)gesture{
    if([gesture state] == UIGestureRecognizerStateChanged){

		[self.dragView setFrame:CGRectFromCGPoints(self.dragView.dragStartPoint, [gesture locationInView:self.view])];

		/*for(OSFileGridTile *tile in self.view.subviews){
			if(![tile isKindOfClass:[OSFileGridTile class]])
				continue;
			if(CGRectIntersectsRect(self.dragView.frame, tile.frame))
				[tile setSelected:true];
			else
				[tile setSelected:false];
		}*/
	}else if([gesture state] == UIGestureRecognizerStateBegan){

		self.dragView = [[OSSelectionDragView alloc] init];
		self.dragView.color = [UIColor lightGrayColor];
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

- (void)updateTiles{
	for(NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.path includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]){
		BOOL tileFound = false;

		for(OSFileGridTile *tile in self.tiles){
			if([URL_STD(tile.url) isEqualToString:URL_STD(url)]){
				tileFound = true;
				break;
			}
		}

		if(!tileFound){
			OSFileGridTile *tile = [self tileForFileAtURL:url];
			[self.tiles addObject:tile];
			[self.view addSubview:tile];
		}
	}
}

- (OSFileGridTile *)tileForFileAtURL:(NSURL*)url{
	OSFileGridTile *tile = [[OSFileGridTile alloc] initWithIconSize:self.iconSize gridSpacing:self.gridSpacing];

	tile.url = url;

	BOOL isDirectory;

	[[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];

	if(isDirectory){
		AIImage *icon = [[AIImage alloc] initWithPath:@"/Library/Application Support/OS Experience/GenericFolderIcon.icns"];
		[tile setIcon:[icon bestImageRepresentationForSize:tile.iconView.bounds.size.height]];
		[icon release];
	}else{
		AIImage *icon = [[AIImage alloc] initWithPath:@"/Library/Application Support/OS Experience/GenericDocumentIcon.icns"];
		[tile setIcon:[icon bestImageRepresentationForSize:tile.iconView.bounds.size.height]];
		[icon release];
	}

	//UIPanGestureRecognizer *fileMoveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFileMoveGesture:)];
	//[tile addGestureRecognizer:fileMoveGesture];
	//[fileMoveGesture release];

	return [tile autorelease];
}

- (void)dealloc{
	[self.path release];
	[super dealloc];
}

@end