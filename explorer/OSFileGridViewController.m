#import "OSFileGridViewController.h"
#import "OSSelectionDragView.h"
#import "CGPointExtension.h"

#define CGRectFromCGPoints(p1, p2) CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y))


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

	self.view.backgroundColor = [UIColor greenColor];

	[self.view release];
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



@end