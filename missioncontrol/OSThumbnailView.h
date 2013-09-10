#import <UIKit/UIKit.h>
#import "OSThumbnailWrapper.h"
#import "OSPaneThumbnail.h"
#import "../OSPaneModel.h"
#import "../OSPane.h"
#import "../explorer/CGPointExtension.h"


#define thumbnailMarginSize 20
#define wrapperCenter 20


@class OSThumbnailWrapper;

@interface OSThumbnailView : UIView{
	OSThumbnailWrapper *_wrapperView;
	UIView *_addDesktopButton;
}

@property (nonatomic, retain) OSThumbnailWrapper *wrapperView;
@property (nonatomic, retain) UIView *addDesktopButton;

+ (id)sharedInstance;

- (BOOL)isPortrait;
- (void)addPane:(OSPane*)pane;
- (void)alignSubviews;
- (BOOL)isPortrait:(UIInterfaceOrientation)orientation;
- (void)removePane:(OSPane*)pane animated:(BOOL)animated;
- (void)updateSelectedThumbnail;

@end