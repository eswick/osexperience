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
	UIInterfaceOrientation _currentOrientation;
	int _pageIndexPlaceholder;
}

@property (nonatomic, retain) NSMutableArray *panes;
@property (nonatomic) CGPoint startingOffset;
@property (nonatomic, readonly) int currentPageIndex;
@property (nonatomic, readonly) OSPane *currentPane;
@property (nonatomic, readwrite) UIInterfaceOrientation currentOrientation;
@property (nonatomic, readwrite) int pageIndexPlaceholder;


+ (id)sharedInstance;
- (void)addPane:(OSPane*)pane;
- (void)updateDockPosition;
- (OSPane*)paneAtIndex:(int)index;
- (BOOL)isPortrait;
//- (void)layoutPanes;
- (void)alignPanes;
//-(void)_endPanWithEvent:(id)event;



@end