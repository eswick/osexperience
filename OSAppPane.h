#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "include.h"
#import "OSTouchForwarder.h"




@interface OSAppPane : OSPane{
	SBApplication *_application;
	SBHostWrapperView *_appView;
}

@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, retain) SBHostWrapperView *appView;

-(id)initWithDisplayIdentifier:(NSString*)displayIdentifier;

@end