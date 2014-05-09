#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "OSPane.h"
#import "include.h"
#import "OSAppWindow.h"
#import "OSPaneModel.h"




@interface OSAppPane : OSPane{
	SBApplication *_application;
	SBHostWrapperView *_appView;
	UIToolbar *_windowBar;
	BOOL _windowBarOpen;
	UIView *_windowBarShadowView;
}

@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, retain) SBHostWrapperView *appView;
@property (nonatomic, retain) UIToolbar *windowBar;
@property (nonatomic, readwrite, getter=windowBarIsOpen) BOOL windowBarOpen;
@property (nonatomic, retain) UIView *windowBarShadowView;

- (id)initWithDisplayIdentifier:(NSString*)displayIdentifier;
- (void)setWindowBarVisible;
- (void)setWindowBarHidden;
- (void)contractButtonPressed;

@end