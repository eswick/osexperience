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
	//self.clipsToBounds = true;


	self.appView = [self.application contextHostViewForRequester:@"WindowManager" enableAndOrderFront:true];
	[self addSubview:self.appView];



	UIView *overlayView = [[UIView alloc] initWithFrame:self.frame];
	overlayView.alpha = 0.1;
	overlayView.backgroundColor = [UIColor grayColor];
	overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	OSTouchForwarder *touchForwarder = [[OSTouchForwarder alloc] initWithApplication:self.application];
    [overlayView addGestureRecognizer:touchForwarder];

	[self addSubview:overlayView];

	[overlayView release];
	[touchForwarder release];

	return self;
}



@end