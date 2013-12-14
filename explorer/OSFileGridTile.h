


@interface OSFileGridTile : UIView

@property (nonatomic, retain) UIImageView *iconView;
@property CGSize iconSize;
@property float gridSpacing;

- (void)setIcon:(UIImage*)icon;
- (id)initWithIconSize:(CGSize)iconSize gridSpacing:(float)spacing;

@end