#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "../OSPane.h"
#import "OSThumbnailView.h"
#import "../OSAppPane.h"


@interface UIView(Additions)

- (BOOL)needsDisplay;

@end


@interface OSPaneThumbnail : UIImageView{
	OSPane *_pane;
	UILabel *_label;
	UIImageView *_icon;
}

@property (nonatomic, retain) OSPane *pane;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *icon;

- (id)initWithPane:(OSPane*)pane;
- (void)updateImage;
- (void)updateSize;
- (void)updateLabel;



@end