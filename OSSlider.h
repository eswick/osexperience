#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "UIView+FrameExtensions.h"






@interface OSSlider : UIScrollView{
	NSMutableArray *_panes;
	CGPoint _startingOffset;
}

@property (nonatomic, retain) NSMutableArray *panes;
@property (nonatomic) CGPoint startingOffset;


+ (id)sharedInstance;
- (void)addPane:(OSPane*)pane;
-(void)gestureBegan:(float)percentage;
-(void)gestureChanged:(float)percentage;
-(void)gestureCancelled;
//-(void)_endPanWithEvent:(id)event;



@end