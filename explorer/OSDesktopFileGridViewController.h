
#import "OSFileViewController.h"

typedef enum{
	OSFileGridViewTypeWindowed,
	OSFileGridViewTypeDesktop
} OSFileGridViewType;


@class OSSelectionDragView, OSFileGridTile, OSFileGridTileMap;

@interface OSDesktopFileGridViewController : OSFileViewController{

}

@property (retain) UIView *view;
@property (retain) OSFileGridTileMap *tileMap;
@property (assign) OSSelectionDragView *dragView;
@property (nonatomic) OSFileGridViewType type;
@property (nonatomic) float gridSpacing;
@property (nonatomic) CGSize iconSize;

- (void)addTile:(OSFileGridTile*)tile atIndex:(int)index;
- (void)moveTile:(OSFileGridTile*)tile toIndex:(int)index;

@end