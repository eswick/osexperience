#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSAppPane.h"
#import "UIView+FrameExtensions.h"
#import "OSViewController.h"
#import "OSPaneModel.h"


@interface OSSlider : UIScrollView <UIScrollViewDelegate> {
	CGPoint _startingOffset;
	int _currentPageIndex;
	OSPane *_currentPane;
	UIInterfaceOrientation _currentOrientation;
	int _pageIndexPlaceholder;
}

@property (nonatomic) CGPoint startingOffset;
@property (nonatomic, readonly) int currentPageIndex;
@property (nonatomic, readonly) OSPane *currentPane;
@property (nonatomic, readwrite) UIInterfaceOrientation currentOrientation;
@property (nonatomic, readwrite) int pageIndexPlaceholder;
@property (nonatomic, readwrite) float pageOffsetBefore;
@property (nonatomic, assign) SBPanGestureRecognizer *swipeGestureRecognizer;


+ (id)sharedInstance;
- (void)addPane:(OSPane*)pane;
- (void)updateDockPosition;
- (BOOL)isPortrait;
- (void)alignPanes;
- (void)scrollToPane:(OSPane*)pane animated:(BOOL)animated;
- (void)updatePaging:(float)percentage;
- (void)beginPaging;
- (void)swipeGestureEndedWithCompletionType:(long long)arg1 cumulativePercentage:(double)arg2;



@end