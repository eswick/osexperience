#import "OSWindow.h"


@interface OSAppWindow : OSWindow{
	SBApplication *_application;
	SBHostWrapperView *_appView;
}

@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, retain) SBHostWrapperView *appView;

- (id)initWithApplication:(SBApplication*)application;
- (void)applicationDidRotate;
- (void)resetHostView;

@end