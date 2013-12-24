
#import "OSFileViewController.h"

typedef enum{
	OSFileGridViewTypeWindowed,
	OSFileGridViewTypeDesktop
} OSFileGridViewType;


@class OSSelectionDragView, OSFileGridTile;

@interface OSFileGridViewController : OSFileViewController{

}

@property (nonatomic, retain) UIScrollView *view;
@property (retain) NSMutableDictionary *tileMap;
@property (assign) OSSelectionDragView *dragView;
@property (nonatomic) OSFileGridViewType type;
@property (nonatomic) float gridSpacing;
@property (nonatomic) CGSize iconSize;

- (void)addTile:(OSFileGridTile*)tile atIndex:(CGPoint)index;
- (void)moveTile:(OSFileGridTile*)tile toIndex:(CGPoint)index;
- (CGPoint)indexOfTile:(OSFileGridTile*)tile;
- (BOOL)containsTile:(OSFileGridTile*)tile;


@end