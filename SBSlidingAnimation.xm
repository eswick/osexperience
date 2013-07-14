#import "OSSlider.h"
#import "OSAppPane.h"





%hook SBAppToAppTransitionView


-(id)initWithFrame:(CGRect)arg1{
	self = %orig;
	[self setHidden:true];
	return self;
}


%end



%hook SBUIAnimationZoomUpApp

- (void)_setHidden:(BOOL)arg1{
	%orig(true);
}


%end