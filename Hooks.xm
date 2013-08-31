#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "launchpad/UIImage+StackBlur.h"
#import <mach/mach_time.h>


extern "C" void BKSTerminateApplicationForReasonAndReportWithDescription(NSString *app, int a, int b, NSString *description);

%group SpringBoard //Springboard hooks


%hook SBWallpaperView

- (BOOL)_shouldShowGradientOverWallpaper{
	return false;
}

%end



%hook SBUIController



- (BOOL)activateSwitcher{

	if([[OSViewController sharedInstance] missionControlIsActive])
		[[OSViewController sharedInstance] setMissionControlActive:false animated:true];
	else
		[[OSViewController sharedInstance] setMissionControlActive:true animated:true];
	

	return true;
}


-(id)init{
	self = %orig;

	[[self rootView] removeFromSuperview];

	OSViewController *viewController = [OSViewController sharedInstance];


	[[UIApp keyWindow] setRootViewController:viewController];
	[viewController.view setFrame:[[UIScreen mainScreen] bounds]];


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

	
	
	[[OSSlider sharedInstance] setPageIndexPlaceholder:[[OSSlider sharedInstance] currentPageIndex]];


	[UIView animateWithDuration:arg3 delay:0.0 options: UIViewAnimationCurveEaseOut animations:^{
		UIView *osView = [[OSViewController sharedInstance] view];
		osView.transform = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
		[osView setFrame:[[UIScreen mainScreen] bounds]];
		[[objc_getClass("SBIconController") sharedInstance] willAnimateRotationToInterfaceOrientation:arg2 duration:arg3];
	}completion:^(BOOL finished){

    }];

	[[OSSlider sharedInstance] willRotateToInterfaceOrientation:arg2 duration:arg3];
	[[OSThumbnailView sharedInstance] willRotateToInterfaceOrientation:arg2 duration:arg3];


	[[objc_getClass("SBIconController") sharedInstance] prepareToRotateFolderAndSlidingViewsToOrientation:arg2];


	[[[[OSViewController sharedInstance] iconContentView] wallpaperView] setOrientation:arg2 duration:arg3];
}


%end




%hook SBScaleGestureRecognizer


-(BOOL)sendsTouchesCancelledToApplication{
	return true;
}

-(BOOL)shouldReceiveTouches{
	return false;
}

%end


%hook SBPanGestureRecognizer

-(BOOL)sendsTouchesCancelledToApplication{
	return true;
}

-(BOOL)shouldReceiveTouches{
	if([self isKindOfClass:[%c(SBOffscreenSwipeGestureRecognizer) class]])
		return true;
	else
		return false;


}

%end



%hook SpringBoard


-(void)sendEvent:(id)arg1{
	GSEventRef event = [arg1 _gsEvent];


	if(GSEventGetType(event) == kGSEventDeviceOrientationChanged){
		for(OSAppPane *appPane in [[OSPaneModel sharedInstance] panes]){
			if(![appPane isKindOfClass:[OSAppPane class]])
				continue;

			[[appPane application] rotateToInterfaceOrientation:GSEventDeviceOrientation(event)];
		}
	}

	if(GSEventGetType(event) == kGSEventKeyUp || GSEventGetType(event) == kGSEventKeyDown){
		if([[[OSSlider sharedInstance] currentPane] isKindOfClass:[OSAppPane class]] && ![[OSViewController sharedInstance] launchpadIsActive]){
			const GSEventRecord* record = _GSEventGetGSEventRecord(event);
			GSSendEvent(record, (mach_port_t)[[(OSAppPane*)[[OSSlider sharedInstance] currentPane] application] eventPort]);
			return;
		}
	}

	%orig;
}


%end







%hook SBApplication

-(void)didExitWithInfo:(id)arg1 type:(int)arg2{

	OSAppPane *appPane;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == self)
			appPane = pane;
	}

	if(appPane)
		[[OSPaneModel sharedInstance] removePane:appPane];


    %orig;
}



%new
-(void)rotateToInterfaceOrientation:(int)orientation{

	uint8_t orientationEvent[sizeof(GSEventRecord) + sizeof(GSDeviceOrientationInfo)];

	struct GSOrientationEvent {
        GSEventRecord record;
        GSDeviceOrientationInfo orientationInfo;
    } * event = (struct GSOrientationEvent*) &orientationEvent;
    
	event->record.type = kGSEventDeviceOrientationChanged;
	event->record.timestamp = mach_absolute_time();
	event->record.senderPID = getpid();
	event->record.infoSize = sizeof(GSDeviceOrientationInfo);
	event->orientationInfo.orientation = orientation;
	
	
	GSSendEvent((GSEventRecord*)event, (mach_port_t)[self eventPort]);

}



-(void)didSuspend{
	
	OSAppPane *appPane;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == self)
			appPane = pane;
	}

	if(appPane)
		[[OSPaneModel sharedInstance] removePane:appPane];



	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", @"performOriginals", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], [NSNumber numberWithBool:false], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageAndReceiveReplyName:@"setApplicationPerformOriginals" userInfo:dictionary];


	%orig;
}

-(void)willActivate{
	%orig;
	[self addToSlider];
 
}

- (void)didLaunch:(BKSApplicationProcessInfo*)arg1{
	%orig;
	if([arg1 suspended]){
		return;
	}

	[self addToSlider];

}


%new
-(void)addToSlider{
	BOOL found = false;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]]){
			continue;
		}
		if(pane.application == self){
			found = true;
		}
	}

	if(!found){
		OSAppPane *appPane = [[OSAppPane alloc] initWithDisplayIdentifier:[self bundleIdentifier]];

		int appViewDegrees;

		switch([UIApp statusBarOrientation]){
			case UIInterfaceOrientationPortrait:
				appViewDegrees = 0;
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				appViewDegrees = 180;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				appViewDegrees = 90;
				break;
			case UIInterfaceOrientationLandscapeRight:
				appViewDegrees = 270;
				break;
		}

		UIView *appView = [appPane appView];
		appView.transform = CGAffineTransformMakeRotation(DegreesToRadians(appViewDegrees));
		CGRect frame = [appView frame];
		frame.origin = CGPointMake(0, 0);
		[appView setFrame:frame];


		[[OSPaneModel sharedInstance] addPaneToBack:appPane];
		[self activate];
		[appPane release];
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



%new
- (void)suspend{

    
	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", @"performOriginals", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], [NSNumber numberWithBool:true], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageAndReceiveReplyName:@"setApplicationPerformOriginals" userInfo:dictionary];


	BKSTerminateApplicationForReasonAndReportWithDescription([self bundleIdentifier], 3, 0, 0);

}


%end


%hook SBFolderSlidingView

- (id)initWithPosition:(int)arg1 folderView:(id)arg2{
	self = %orig;

	[[self valueForKey:@"dockView"] setHidden:true];
	[[self valueForKey:@"outgoingDockView"] setHidden:true];
	[[self valueForKey:@"wallpaperView"] setImage:[[[[OSViewController sharedInstance] iconContentView] wallpaperView] image]];


	return self;
}


%end

%hook SBAwayController

-(void)lock{
	[[OSViewController sharedInstance] setLaunchpadActive:false animated:false];
    %orig;
}

- (void)setLocked:(BOOL)arg1{
	if(!arg1){
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{	
			[[UIApp statusBarWindow] setAlpha:0.0];
		}completion:^(BOOL finished){
		}];
	}else{
		[[UIApp statusBarWindow] setAlpha:1.0];
	}
	%orig;
}

%end



%hook SBIconController


-(void)iconWasTapped:(SBApplicationIcon*)arg1{
	[arg1 launchFromViewSwitcher];


	for(OSAppPane *pane in [[OSSlider sharedInstance] subviews]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == arg1.application){
			[[OSSlider sharedInstance] scrollToPane:pane animated:true];
		}
	}

}


-(void)iconTapped:(SBIconView*)arg1{
    if(![[OSViewController sharedInstance] launchpadIsActive]){
        %orig;
        return;
    }
    
    if([[arg1 icon] isFolderIcon] || [[arg1 icon] isNewsstandIcon]){
        [[arg1 icon] launch];
    }else{
        [[OSViewController sharedInstance] deactivateLaunchpadWithIconView:arg1];
        %orig;
    }

}


%end


//App launch animations
%hook SBAppToAppTransitionView


-(id)initWithFrame:(CGRect)arg1{
	self = %orig;
	[self setHidden:true];
	return self;
}


%end


%hook SBUIAnimationZoomUpApp

- (void)_startAnimation{
	[self animationDidStop:@"AnimateResumption" finished:[NSNumber numberWithInt:1] context:0x0];
	[self _cleanupAnimation];
}

%end


//Multitasking things
%hook BKSWorkspace

- (id)topApplication{
	return nil;
}

%end

%end




//Backboard hooks


%group Backboard

%hook BKWorkspaceServerManager



-(id)init{
	self = %orig;


	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];
	[messagingCenter runServerOnCurrentThread];
	[messagingCenter registerForMessageName:@"activate" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	[messagingCenter registerForMessageName:@"setApplicationPerformOriginals" target:self selector:@selector(handleMessageNamed:withUserInfo:)];

	return self;
}


%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
	if([name isEqualToString:@"activate"]){
	
		BKApplication *application = [self applicationForBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"]];

		BKWorkspaceServer *server = [self workspaceForApplication:application];
	
		[server _activate:application activationSettings:nil deactivationSettings:nil token:[objc_getClass("BKSWorkspaceActivationToken") token]];
	
	}else if([name isEqualToString:@"setApplicationPerformOriginals"]){
		BKApplication *application = [self applicationForBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"]];
		[application setPerformOriginals:[[userinfo objectForKey:@"performOriginals"] boolValue]];
		
	}

	return nil;
}

- (unsigned int)currentEventPort{
	return [self portForBundleIdentifier:@"com.apple.springboard"];
}

%end





%hook BKApplication

static char originalsKey;

%new
- (void)setPerformOriginals:(BOOL)performOriginals{
	objc_setAssociatedObject(self, &originalsKey, [NSNumber numberWithBool:performOriginals], OBJC_ASSOCIATION_RETAIN);
}

%new
- (BOOL)performOriginals{
	return [objc_getAssociatedObject(self, &originalsKey) boolValue];
}


-(void)_deactivate:(id)arg1{
	if([self performOriginals]){
		%orig;
	}
}

%end

%hook BKSWorkspace

- (id)topApplication{
	return nil;
}

%end

%end



__attribute__((constructor))
static void initialize() {
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.backboardd"])
		%init(Backboard);
	

	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		%init(SpringBoard);
	
}
