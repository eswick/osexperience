

@class OSFileGridTileLabel, OSPathFillView, OSFileGridTileGhostView;

@interface OSFileGridTile : UIView

@property (nonatomic, retain) UIImageView *iconView;
@property (retain) OSFileGridTileLabel *label;
@property (retain) UIView *selectionBackdrop;
@property (nonatomic, retain) NSURL *url;
@property CGPoint gridLocation;
@property CGSize iconSize;
@property float gridSpacing;
@property (nonatomic) BOOL selected;
@property (assign) OSFileGridTileGhostView *ghostView;

- (id)initWithIconSize:(CGSize)iconSize gridSpacing:(float)spacing;
- (void)setIcon:(UIImage*)icon;

@end