#import <UIKit/UIKit.h>
#import "OSThumbnailWrapper.h"
#import "OSPaneThumbnail.h"
#import "../OSPaneModel.h"
#import "../OSPane.h"
#import "../explorer/CGPointExtension.h"
#import "OSAddDesktopButton.h"


#define thumbnailMarginSize 20
#define wrapperCenter 20


@class OSThumbnailWrapper;

@interface OSThumbnailView : UIView{
	OSThumbnailWrapper *_wrapperView;
	OSAddDesktopButton *_addDesktopButton;
}

@property (nonatomic, retain) OSThumbnailWrapper *wrapperView;
@property (nonatomic, retain) OSAddDesktopButton *addDesktopButton;

+ (id)sharedInstance;

- (BOOL)isPortrait;
- (void)addPane:(OSPane*)pane;
- (void)alignSubviews;
- (BOOL)isPortrait:(UIInterfaceOrientation)orientation;
- (void)removePane:(OSPane*)pane animated:(BOOL)animated;
- (void)updateSelectedThumbnail;

@end