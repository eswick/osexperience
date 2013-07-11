#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>




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


	OSViewController *viewController = [OSViewController sharedInstance];

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
	%orig;
}




- (void)_switchAppGestureCancelled{
	[[OSSlider sharedInstance] gestureCancelled];
}

- (void)_switchAppGestureEndedWithCompletionType:(int)arg1 cumulativePercentage:(float)arg2{
	[[OSSlider sharedInstance] gestureCancelled];
}



- (void)_switchAppGestureChanged:(float)arg1{
	[[OSSlider sharedInstance] gestureChanged:arg1];
}
- (void)_switchAppGestureBegan:(float)arg1{
	[[OSSlider sharedInstance] gestureBegan:arg1];
}




-(void)activateApplicationFromSwitcher:(id)arg1{
	//[self activateApplicationAnimated:arg1];
	%orig;
}

- (BOOL)shouldSendTouchesToSystemGestures{
	return true;
}

%end







//Background process handling


%hook BKWorkspaceServerManager



-(id)init{
	self = %orig;


	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];
	[messagingCenter runServerOnCurrentThread];
	[messagingCenter registerForMessageName:@"activate" target:self selector:@selector(handleMessageNamed:withUserInfo:)];

	return self;
}


%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
	if(![name isEqualToString:@"activate"]){
		return nil;
	}

	BKApplication *application = [self applicationForBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"]];

	/*
	if(application == nil){
		dispatch_queue_t queue = dispatch_queue_create("com.apple.backboard.xpc.defaultHandler", NULL);
		application = [[objc_getClass("BKApplication") alloc] initWithBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"] queue:queue];
	}*/

	BKWorkspaceServer *server = [self workspaceForApplication:application];
	
	[server _activate:application activationSettings:nil deactivationSettings:nil token:[objc_getClass("BKSWorkspaceActivationToken") token]];
	
	return nil;
}


%end



%hook SBApplication

-(void)didSuspend{
	%orig;
}

-(void)willActivate{
	%orig;
	[self addToSlider];
 
}

- (void)didLaunch:(BKSApplicationProcessInfo*)arg1{
	%orig;
	NSLog(@"%@", arg1);
	if([arg1 suspended]){
		return;
	}

	[self addToSlider];

}


%new
-(void)addToSlider{
	BOOL found = false;

	for(OSAppPane *pane in [[OSSlider sharedInstance] subviews]){
		if(![pane isKindOfClass:[OSAppPane class]]){
			continue;
		}
		if(pane.application == self){
			found = true;
		}
	}

	if(!found){
		OSAppPane *appPane = [[OSAppPane alloc] initWithDisplayIdentifier:[self bundleIdentifier]];
		[[OSSlider sharedInstance] addPane:appPane];
		[self activate];
	}
}

- (void)activate{
	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageName:@"activate" userInfo:dictionary];
}




/*
- (void)setActivationSetting:(unsigned int)arg1 flag:(BOOL)arg2{
	NSLog(@"Activation setting set!");
	if(arg1 == 2){
		//%orig(2, true);
		%orig;
	}else{
		%orig;
	}

}


- (BOOL)activationFlag:(unsigned int)arg1{

	if(arg1 == 2){
		NSLog(@"Activation flag 2!");
		return %orig;
	}else{
		return %orig;
	}
}*/

%end




%hook SBDockIconListView



- (id)initForOrientation:(int)arg1 viewMap:(id)arg2{
	NSLog(@"SBDockIconListView init; viewMap: %@", arg2);
	return %orig;
}


%end



%hook SBWorkspace

- (void)workspace:(id)arg1 applicationActivated:(id)arg2{
	%orig(arg1, arg2);
}



- (void)workspace:(id)arg1 applicationDidBecomeReceiver:(id)arg2 fromApplication:(id)arg3{
	%orig(arg1, arg2, nil);
	//[[[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:arg3] activate];
}

- (id)workspace:(id)arg1 applicationWillBecomeReceiver:(id)arg2 fromApplication:(id)arg3{
	return %orig(arg1, arg2, nil);
}




%end


%hook BKProcess

- (BOOL)_taskSuspend{
	return true;
}

- (void)setFrontmost:(BOOL)arg1{
	if(!arg1){
		[self killWithSignal:0]; //Not completley sure if this is needed or not...
		return;
	}
	%orig;
}

- (BOOL)_suspend{
	return true;
}


%end




%hook BKApplication

-(void)_deactivate:(id)arg1{
	if([self suspendType] == 0){
		[self setSuspendType:1];
	}
}

%end


