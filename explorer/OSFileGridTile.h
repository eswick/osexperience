


@interface OSFileGridTile : UIView

@property (nonatomic, retain) UIImageView *iconView;
@property (retain) UILabel *label;
@property (nonatomic, retain) NSURL *URL;
@property CGSize iconSize;
@property float gridSpacing;

- (id)initWithIconSize:(CGSize)iconSize gridSpacing:(float)spacing;
- (void)setIcon:(UIImage*)icon;

@end