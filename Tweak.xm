#import "include.h"
#import "OSViewController.h"




@interface SBUIController(OSExtensions)

-(id)osView;
-(void)setOSView:(id)arg1;

@end



%hook SBUIController

static char osViewKey;


%new
-(id)osView{
	return objc_getAssociatedObject(self, &osViewKey);
}


%new
- (void)setOSView:(id)arg1{
    objc_setAssociatedObject(self, &osViewKey, arg1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



-(id)init{
	self = %orig;

	[[self rootView] removeFromSuperview];


	OSViewController *viewController = [[OSViewController alloc] init];

	[UIApp.keyWindow addSubview:viewController.view];
	[UIApp.keyWindow setRootViewController:viewController];
	[self setOSView:viewController.view];



	return self;
}



- (void)window:(id)arg1 willAnimateRotationToInterfaceOrientation:(int)arg2 duration:(double)arg3{
	%orig;


	int degrees;

	switch(arg2){
		case UIInterfaceOrientationPortrait:
			degrees = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			degrees = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			degrees = 270;
			break;
		case UIInterfaceOrientationLandscapeRight:
			degrees = 90;
			break;
	}

	[UIView beginAnimations:@"rotate" context:nil];
	[UIView setAnimationDuration:arg3];

	UIView *osView = [self osView];
	osView.transform = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	[osView setFrame:[[UIScreen mainScreen] bounds]];

	[UIView commitAnimations];

}


- (void)handleFluidVerticalSystemGesture:(id)arg1{

}

- (void)handleFluidHorizontalSystemGesture:(id)arg1{

}


- (void)_switchAppGestureChanged:(float)arg1{
	NSLog(@"Switch app gesture changed: %f", arg1);
	%orig;
}


%end