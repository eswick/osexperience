
#import "OSFileViewController.h"

typedef enum{
	OSFileGridViewTypeWindowed,
	OSFileGridViewTypeDesktop
} OSFileGridViewType;


@class OSSelectionDragView;

@interface OSFileGridViewController : OSFileViewController{

}

@property (nonatomic, retain) UIScrollView *view;
@property (assign) OSSelectionDragView *dragView;
@property (nonatomic) OSFileGridViewType type;
@property (nonatomic) float gridSpacing;
@property (nonatomic) CGSize iconSize;

@end