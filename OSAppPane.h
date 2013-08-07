#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "OSPane.h"
#import "include.h"
#import "OSTouchForwarder.h"




@interface OSAppPane : OSPane{
	SBApplication *_application;
	SBHostWrapperView *_appView;
	UIToolbar *_windowBar;
}

@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, retain) SBHostWrapperView *appView;
@property (nonatomic, retain) UIToolbar *windowBar;

-(id)initWithDisplayIdentifier:(NSString*)displayIdentifier;

@end