#import "OSAppPane.h"





@implementation OSAppPane
@synthesize application = _application;
@synthesize appView = _appView;





-(id)initWithDisplayIdentifier:(NSString*)displayIdentifier{
	self.application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:displayIdentifier];


	if(![super initWithName:self.application.displayName thumbnail:nil]){
		return nil;
	}

	

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.clipsToBounds = true;


	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];
	[self addSubview:self.appView];

	

	return self;
}





@end