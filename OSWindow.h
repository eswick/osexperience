#import <UIKit/UIKit.h>
#import "include.h"


@class OSWindow;


@protocol OSWindowDelegate

- (void)window:(OSWindow*)window didRecievePanGesture:(UIPanGestureRecognizer*)gesture;

@end


@interface OSWindow : UIView{
	UIToolbar *_windowBar;
	id<OSWindowDelegate> _delegate;
	CGPoint _grabPoint;
}

@property (nonatomic, retain) UIToolbar *windowBar;
@property (nonatomic, assign) id<OSWindowDelegate> delegate; 
@property (nonatomic, readwrite) CGPoint grabPoint;

- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title;
- (void)stopButtonPressed;

@end


