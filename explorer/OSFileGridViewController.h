#import "OSFileViewController.h"

@class OSSelectionDragView;

@interface OSFileGridViewController : OSFileViewController

@property (assign) OSSelectionDragView *dragView;
@property (nonatomic) float gridSpacing;
@property (nonatomic) CGSize iconSize;

@end