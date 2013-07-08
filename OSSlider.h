#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "UIView+FrameExtensions.h"






@interface OSSlider : UIScrollView{
	NSMutableArray *_panes;
}

@property (nonatomic, retain) NSMutableArray *panes;


-(void)addPane:(OSPane*)pane;





@end