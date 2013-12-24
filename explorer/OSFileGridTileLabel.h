#import <CoreText/CoreText.h>


@interface OSFileGridTileLabel : UILabel

@property (retain) UIBezierPath *path;
@property (nonatomic, assign) BOOL selected;
@property (assign) CTFrameRef textFrame;

- (UIBezierPath*)pathWithTopLine:(CGRect)topLine bottomLine:(CGRect)bottomLine;

- (void)redrawText;
- (void)updateSelectionPath;


@end