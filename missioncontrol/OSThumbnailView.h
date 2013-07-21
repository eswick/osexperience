#import <UIKit/UIKit.h>
#import "OSThumbnailWrapper.h"
#import "OSPaneThumbnail.h"
#import "../OSPaneModel.h"
#import "../OSPane.h"

#define thumbnailMarginSize 20
#define wrapperCenter 20


@class OSThumbnailWrapper, OSPaneThumbnail, OSPane, OSPaneModel;

@interface OSThumbnailView : UIView{
	OSThumbnailWrapper *_wrapperView;
}

@property (nonatomic, retain) OSThumbnailWrapper *wrapperView;

+ (id)sharedInstance;

- (BOOL)isPortrait;
- (void)addPane:(OSPane*)pane;
- (void)alignPanes;
- (void)alignWrapper;


@end