#import <UIKit/UIKit.h>
#import "include.h"
#import "explorer/CGPointExtension.h"


@class OSWindow;


@protocol OSWindowDelegate

- (void)window:(OSWindow*)window didRecievePanGesture:(UIPanGestureRecognizer*)gesture;
- (void)window:(OSWindow*)window didRecieveResizePanGesture:(UIPanGestureRecognizer*)gesture;

@end


@interface OSWindow : UIView{
	UIToolbar *_windowBar;
	id<OSWindowDelegate> _delegate;
	CGPoint _grabPoint;
	CGPoint _resizeAnchor;
	UIBarButtonItem *_expandButton;
}

@property (nonatomic, retain) UIToolbar *windowBar;
@property (nonatomic, assign) id<OSWindowDelegate> delegate; 
@property (nonatomic, readwrite) CGPoint resizeAnchor;
@property (nonatomic, readwrite) CGPoint grabPoint;
@property (nonatomic, retain) UIBarButtonItem *expandButton;

- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title;
- (void)stopButtonPressed;
- (CGRect) CGRectFromCGPoints:(CGPoint)p1 p2:(CGPoint)p2;

@end


