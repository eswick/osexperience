#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSAppPane.h"
#import "UIView+FrameExtensions.h"
#import "OSViewController.h"






@interface OSSlider : UIScrollView <UIScrollViewDelegate> {
	NSMutableArray *_panes;
	CGPoint _startingOffset;
	int _currentPageIndex;
	OSPane *_currentPane;
}

@property (nonatomic, retain) NSMutableArray *panes;
@property (nonatomic) CGPoint startingOffset;
@property (nonatomic, readonly) int currentPageIndex;
@property (nonatomic, readonly) OSPane *currentPane;


+ (id)sharedInstance;
- (void)addPane:(OSPane*)pane;
- (void)gestureBegan:(float)percentage;
- (void)gestureChanged:(float)percentage;
- (void)gestureCancelled;
- (void)updateDockPosition;
-(OSPane*)paneAtIndex:(int)index;
//-(void)_endPanWithEvent:(id)event;



@end