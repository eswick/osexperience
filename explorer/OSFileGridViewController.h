#import "OSFileViewController.h"

@class OSSelectionDragView;

@interface OSFileGridViewController : OSFileViewController

@property (assign) OSSelectionDragView *dragView;
@property (retain) NSMutableArray *tiles;
@property (nonatomic) float gridSpacing;
@property (nonatomic) CGSize iconSize;

@end