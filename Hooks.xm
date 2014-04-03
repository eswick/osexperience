#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import <mach/mach_time.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <substrate.h>
#import "OSRemoteRenderLayer.h"
#import "explorer/OSExplorerWindow.h"


extern "C" void BKSTerminateApplicationForReasonAndReportWithDescription(NSString *app, int a, int b, NSString *description);
extern "C" CFTypeRef SecTaskCopyValueForEntitlement(/*SecTaskRef*/void* task, CFStringRef entitlement, CFErrorRef *error);//In Security.framework

#define notificationCenterID @"com.eswick.osexperience.notificationCenter"
#define explorerIconDisplayName @"OS Explorer"
#define explorerIconIdentifier @"com.eswick.osexperience.osexplorer"

%group SpringBoard //Springboard hooks

/* ------------------------------ */

%hook SBWallpaperView

- (BOOL)_shouldShowGradientOverWallpaper{
	return false;
}

%end

%hook SBAppContextHostView

+ (Class)layerClass{
	return [OSRemoteRenderLayer class];
}

- (void)setManager:(id)manager{
	[(OSRemoteRenderLayer*)self.layer setManager:manager];
	%orig;
}

%end

%hook SBPanGestureRecognizer

- (id)initForHorizontalPanning{
	self = %orig;
	[[OSSlider sharedInstance] setSwipeGestureRecognizer:self];
	return self;
}

%end

%hook SBScaleGestureRecognizer

- (void)setRequiredDirectionality:(int)directionality{
	%orig(0);
}

%end

%hook SBUIController

- (void)handleFluidVerticalSystemGesture:(SBPanGestureRecognizer*)arg1{
	static BOOL upGestureWasRecognized = false;
	static BOOL downGestureWasRecognized = false;

	if([arg1 state] == UIGestureRecognizerStateEnded || [arg1 state] == UIGestureRecognizerStateCancelled){
		upGestureWasRecognized = false;
		downGestureWasRecognized = false;
		return;
	}

	if([arg1 cumulativeMotion] == [arg1 animationDistance]){
		upGestureWasRecognized = false;
		if(!downGestureWasRecognized){
			[[OSViewController sharedInstance] handleDownGesture];
			downGestureWasRecognized = true;
		}
	}else if([arg1 cumulativeMotion] == -[arg1 animationDistance]){
		downGestureWasRecognized = false;
		if(!upGestureWasRecognized){
			[[OSViewController sharedInstance] handleUpGesture];
			upGestureWasRecognized = true;
		}

	}

}

- (void)_suspendGestureCleanUpState{
}

- (void)_suspendGestureCancelled{
	[[OSViewController sharedInstance] setLaunchpadAnimating:false];
}

- (void)_suspendGestureEndedWithCompletionType:(long long)arg1{
	if(arg1 == 1){

		[UIView animateWithDuration:0.25
			delay:0
			options: UIViewAnimationOptionCurveEaseOut 
			animations:^{
				[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:1];
				[[OSViewController sharedInstance] setDockPercentage:0.0];
		}completion:^(BOOL completed){
				[[OSViewController sharedInstance] setLaunchpadActive:true];
				[[OSViewController sharedInstance] setLaunchpadAnimating:false];
		}];
		
	}else{
		[UIView animateWithDuration:0.25
			delay:0
			options: UIViewAnimationOptionCurveEaseOut 
			animations:^{
				[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:0];
		}completion:^(BOOL completed){
				[[OSViewController sharedInstance] setLaunchpadActive:false];
				[[OSViewController sharedInstance] setLaunchpadAnimating:false];
		}];
	}
}

- (void)handleFluidScaleSystemGesture:(SBScaleGestureRecognizer*)arg1{
	static BOOL launchpadClosing = false;

	float percentage = [arg1 cumulativeMotion] / [arg1 animationDistance];

	if([arg1 state] == UIGestureRecognizerStateBegan){
		launchpadClosing = [[OSViewController sharedInstance] launchpadIsActive];

		if(![[OSViewController sharedInstance] launchpadIsActive]){
			[[[OSViewController sharedInstance] iconContentView] prepareForDisplay];
		}

		[[OSViewController sharedInstance] setLaunchpadAnimating:true];
	}else if([arg1 state] == UIGestureRecognizerStateChanged){
		if(!launchpadClosing){
			[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:-percentage];
			if(![[[OSSlider sharedInstance] currentPane] showsDock])
				[[OSViewController sharedInstance] setDockPercentage:1 - (-percentage)];
		}else{
			[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:1 - (percentage)];
			if(![[[OSSlider sharedInstance] currentPane] showsDock])
				[[OSViewController sharedInstance] setDockPercentage:percentage];
		}
	}else if([arg1 state] == UIGestureRecognizerStateEnded){
		[[OSViewController sharedInstance] setLaunchpadAnimating:false];

		if([arg1 completionTypeProjectingMomentumForInterval:3.0] != -1){
			if(!launchpadClosing){
				[UIView animateWithDuration:0.25
					delay:0
					options: UIViewAnimationOptionCurveEaseOut 
					animations:^{
						[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:1];
						[[OSViewController sharedInstance] setDockPercentage:0.0];
					}completion:^(BOOL completed){
						[[OSViewController sharedInstance] setLaunchpadActive:true];
						[[OSViewController sharedInstance] setLaunchpadAnimating:false];
					}];
			}else{
				[UIView animateWithDuration:0.25
					delay:0
					options: UIViewAnimationOptionCurveEaseOut 
					animations:^{
						[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:0];
						[[OSViewController sharedInstance] setLaunchpadActive:false];
						[[OSSlider sharedInstance] updateDockPosition];
					}completion:^(BOOL completed){
						[[OSViewController sharedInstance] setLaunchpadAnimating:false];
					}];
			}
		}else{
			[UIView animateWithDuration:0.25
				delay:0
				options: UIViewAnimationOptionCurveEaseOut 
				animations:^{
					[[OSSlider sharedInstance] updateDockPosition];
					[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:0];
				}completion:^(BOOL completed){
					[[OSViewController sharedInstance] setLaunchpadActive:false];
					[[OSViewController sharedInstance] setLaunchpadAnimating:false];
				}];
		}
	}


}

- (void)_suspendGestureChanged:(float)arg1{
	%log;
	[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:arg1];

	
}

- (void)_suspendGestureBegan{

}

- (void)_switchAppGestureBegan:(double)arg1{
	if(![[OSViewController sharedInstance] launchpadIsAnimating] && ![[OSViewController sharedInstance] launchpadIsActive])
		[[OSSlider sharedInstance] beginPaging];
}

- (void)_switchAppGestureChanged:(double)arg1{
	if(![[OSViewController sharedInstance] launchpadIsAnimating] && ![[OSViewController sharedInstance] launchpadIsActive])
		[[OSSlider sharedInstance] updatePaging:arg1];
}

- (void)_switchAppGestureCancelled{
	[[OSSlider sharedInstance] swipeGestureEndedWithCompletionType:0 cumulativePercentage:0];
}

- (void)_switchAppGestureEndedWithCompletionType:(long long)arg1 cumulativePercentage:(double)arg2{
	if(![[OSViewController sharedInstance] launchpadIsAnimating] && ![[OSViewController sharedInstance] launchpadIsActive])
		[[OSSlider sharedInstance] swipeGestureEndedWithCompletionType:arg1 cumulativePercentage:arg2];
}

- (void)_setToggleSwitcherAfterLaunchApp:(id)arg1{
}

- (BOOL)isAppSwitcherShowing{
	return [[OSViewController sharedInstance] missionControlIsActive];
}

- (BOOL)_activateAppSwitcherFromSide:(int)arg1{
	[[OSViewController sharedInstance] setMissionControlActive:true animated:true];
	return true;
}

- (void)dismissSwitcherAnimated:(BOOL)arg1{
	[[OSViewController sharedInstance] setMissionControlActive:false animated:arg1];
}

- (void)_toggleSwitcher{

	if([[OSViewController sharedInstance] missionControlIsActive])
		[[OSViewController sharedInstance] setMissionControlActive:false animated:true];
	else
		[[OSViewController sharedInstance] setMissionControlActive:true animated:true];
}


-(id)init{
	self = %orig;

	[[self contentView] removeFromSuperview];

	OSViewController *viewController = [OSViewController sharedInstance];


	[[UIApp keyWindow] setRootViewController:viewController];
	[viewController.view setFrame:[[UIScreen mainScreen] bounds]];

	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"context", nil];
	NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInt:[[UIApp keyWindow] _contextId]], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageAndReceiveReplyName:@"setKeyWindowContext" userInfo:dictionary];

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


	//[[objc_getClass("SBIconController") sharedInstance] prepareToRotateFolderAndSlidingViewsToOrientation:arg2];


	//[[[[OSViewController sharedInstance] iconContentView] wallpaperView] setOrientation:arg2 duration:arg3];
}

- (BOOL)hasPendingAppActivatedByGesture{
	return true;
}

%end

%hook SpringBoard

- (id)_accessibilityFrontMostApplication{
	return @"LOL";
}

- (void)sendEvent:(id)arg1{
	%orig;
	return;

	if([arg1 isKindOfClass:[%c(UIMotionEvent) class]]){
		%orig;
		return;
	}

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
		}else if([[[OSSlider sharedInstance] currentPane] isKindOfClass:[OSDesktopPane class]] && ![[OSViewController sharedInstance] launchpadIsActive]){
			OSDesktopPane *pane = (OSDesktopPane*)[[OSSlider sharedInstance] currentPane];
			if([pane activeWindow]){
				if([[pane activeWindow] isKindOfClass:[OSAppWindow class]]){
					const GSEventRecord* record = _GSEventGetGSEventRecord(event);
					GSSendEvent(record, (mach_port_t)[[(OSAppWindow*)[pane activeWindow] application] eventPort]);
				}
			}
		}
	}

	%orig;
}

- (void)_handleMenuButtonEvent{
	if([UIApp isLocked])
		return;
	if([[OSViewController sharedInstance] launchpadIsActive])
		[[OSViewController sharedInstance] setLaunchpadActive:false animated:true];
	else
		[[OSViewController sharedInstance] setLaunchpadActive:true animated:true];
}

- (void)applicationDidFinishLaunching:(id)arg1{
	%orig;

	CPDistributedNotificationCenter* notificationCenter = [CPDistributedNotificationCenter centerNamed:notificationCenterID];
	[notificationCenter startDeliveringNotificationsToMainThread];
 
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
       	selector:@selector(notificationRecieved:)
        name:@"cancelTouches"
        object:notificationCenter
    ];
}

%new
- (void)notificationRecieved:(NSNotification *)notification {
	[UIApp _cancelAllTouches];
}

%end

%hook SBHandMotionExtractor

- (void)extractHandMotionForActiveTouches:(SBGestureRecognizerTouchData *)arg1 count:(unsigned int)arg2 centroid:(struct CGPoint)arg3{

	if(arg2 < 4 && arg1[0].type == 0){
		for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
			if(![pane isKindOfClass:[OSDesktopPane class]])
				continue;
			for(OSWindow *window in pane.subviews){
				if(![window isKindOfClass:[OSWindow class]])
					continue;
				CGPoint point = [[[OSViewController sharedInstance] view] convertPoint:arg1[0].location toView:window];
				if([window pointInside:point withEvent:nil]){
					[pane bringSubviewToFront:window];
					[pane setActiveWindow:window];
				}
			}
		}
	}

	%orig;
}
%end



%hook SBApplication

- (void)setDisplaySetting:(unsigned int)arg1 value:(id)arg2{
	%orig;
	if(arg1 == 5){//Rotation changed
		for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
			if([pane isKindOfClass:[OSDesktopPane class]]){
				for(OSAppWindow *window in pane.subviews){
					if(![window isKindOfClass:[OSAppWindow class]])
						continue;
					if(window.application == self){
						[window applicationDidRotate];
						return;
					}
				}
				continue;
			}else if(![pane isKindOfClass:[OSAppPane class]])
				continue;

			if([(OSAppPane*)pane application] == self){

			}
		}
	}
}

-(void)didExitWithInfo:(id)arg1 type:(int)arg2{

	OSAppPane *appPane = nil;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == self)
			appPane = pane;
	}


	if(appPane){
		[[OSPaneModel sharedInstance] removePane:appPane];
	}else{

		for(OSDesktopPane *desktop in [[OSPaneModel sharedInstance] panes]){
			if(![desktop isKindOfClass:[OSDesktopPane class]])
				continue;

			for(OSAppWindow *window in desktop.windows){
				if(![window isKindOfClass:[OSAppWindow class]])
					continue;
				if(window.application == self){
					[desktop.windows removeObject:window];
					[window removeFromSuperview];
				}
			}

		}
	}



    %orig;
}


-(void)didSuspend{
	
	OSAppPane *appPane = nil;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == self)
			appPane = pane;
	}

	if(appPane){
		[[OSPaneModel sharedInstance] removePane:appPane];
	}


	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", @"performOriginals", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], [NSNumber numberWithBool:false], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageAndReceiveReplyName:@"setApplicationPerformOriginals" userInfo:dictionary];


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

	OSAppPane *foundPane = nil;
	OSAppWindow *foundWindow = nil;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]]){
			continue;
		}
		if(pane.application == self){
			found = true;
			foundPane = pane;
		}
	}

	for(OSDesktopPane *desktopPane in [[OSPaneModel sharedInstance] panes]){
		if(![desktopPane isKindOfClass:[OSDesktopPane class]])
			continue;
		for(OSAppWindow *window in desktopPane.windows){
			if(![window isKindOfClass:[OSAppWindow class]])
				continue;
			if(window.application == self){
				found = true;
				foundWindow = window;
			}
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

		[[OSSlider sharedInstance] scrollToPane:appPane animated:true];

		[appPane release];
	}

	if(found){
		if(foundPane){
			[[OSSlider sharedInstance] scrollToPane:foundPane animated:true];
		}
		if(foundWindow){
			[[OSSlider sharedInstance] scrollToPane:[[OSPaneModel sharedInstance] desktopPaneContainingWindow:foundWindow] animated:true];
		}
	}

}

- (void)activate{
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageName:@"activate" userInfo:dictionary];
}



%new
- (void)suspend{

    
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", @"performOriginals", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], [NSNumber numberWithBool:true], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageAndReceiveReplyName:@"setApplicationPerformOriginals" userInfo:dictionary];


	BKSTerminateApplicationForReasonAndReportWithDescription([self bundleIdentifier], 3, 0, 0);

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
			[[(SpringBoard*)UIApp statusBarWindow] setAlpha:0.0];
		}completion:^(BOOL finished){
		}];
	}else{
		[[(SpringBoard*)UIApp statusBarWindow] setAlpha:1.0];
	}
	%orig;
}

%end

%hook SBIconController

-(void)iconWasTapped:(SBApplicationIcon*)arg1{
	if(![[arg1 application] isRunning]){
		[[arg1 application] icon:arg1 launchFromLocation:0];
	}else{
		[[arg1 application] addToSlider];
	}
}


-(void)iconTapped:(SBIconView*)arg1{
	%log;
	[arg1 setHighlighted:false];

    if(![[OSViewController sharedInstance] launchpadIsActive]){
        %orig;
        return;
    }

    if([[arg1 icon] isFolderIcon] || [[arg1 icon] isNewsstandIcon]){
        [[arg1 icon] launchFromLocation:0];
    }else{
        [[OSViewController sharedInstance] deactivateLaunchpadWithIconView:arg1];
        %orig;
    }
}

- (void)_resetRootIconLists{
	%orig;

	[[[OSViewController sharedInstance] dock] removeFromSuperview];

	[[OSViewController sharedInstance] setDock:[[[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] contentView] dockView]];
	CGRect dockFrame = [[[OSViewController sharedInstance] dock] frame];
	dockFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - dockFrame.size.height;
	[[[OSViewController sharedInstance] dock] setFrame:dockFrame];
	[[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];
}

%end

/* Block app launch animation */
%hook SBIconAnimator

- (void)_setAnimationFraction:(float)arg1{
}

- (void)setFraction:(float)arg1{
}

- (void)_prepareAnimation{
}

- (void)prepare{
}

- (void)_cleanupAnimation{
}

- (void)cleanup{
}

%end

%hook SBUIAnimationZoomUpAppFromHome

- (void)prepareZoom{
}

%end

%hook SBUIAnimationController

- (void)__cleanupAnimation{
	[self _setAnimationState:3];
	[self _releaseActivationAssertion];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SBApplicationActivationStateDidChange" object:nil];
	[[%c(SBAlertItemsController) sharedInstance] setForceAlertsToPend:false forReason:[self _animationIdentifier]];

	[UIWindow _synchronizeDrawing];
}

- (void)dealloc{
	[self _setAnimationState:4];
	%orig;
}

%end

%hook SBUIMainScreenAnimationController

- (void)_cleanupAnimation{
}

%end

%hook SBRootFolderController

- (void)setDockOffscreenFraction:(double)arg1{
}

%end

%hook SBAppToAppWorkspaceTransaction

- (void)_commit{
	[self _setupAnimation];
	[self _kickOffActivation];

	SBUIAnimationController *animationController = MSHookIvar<SBUIAnimationController*>(self, "_animationController");
	[animationController beginAnimation];
	
	struct objc_super superInfo = {
        self,
        [self superclass]
    };

    objc_msgSendSuper(&superInfo, @selector(_commit));

    [self animationController:nil willBeginAnimation:nil];
    [self animationControllerDidFinishAnimation:nil];
}

%end

//Multitasking things
%hook BKSWorkspace

- (id)topApplication{
	return nil;
}

%end

MSHook (CFTypeRef, SecTaskCopyValueForEntitlement, void *task, CFStringRef entitlement, CFErrorRef *error){
	CFTypeRef value = _SecTaskCopyValueForEntitlement(task, entitlement, error);

	NSString *nsEntitlement = (NSString*)entitlement;
	if([nsEntitlement isEqualToString:@"com.apple.springboard.openurlinbackground"]){
		value = kCFBooleanTrue;
	}
	
	return value;
}

%end




//Backboard hooks


%group Backboard

static unsigned int springBoardContext;
static BOOL missionControlActive;

%hook BKWorkspaceServerManager

-(id)init{
	self = %orig;


	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];
	[messagingCenter runServerOnCurrentThread];
	[messagingCenter registerForMessageName:@"activate" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	[messagingCenter registerForMessageName:@"setApplicationPerformOriginals" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	[messagingCenter registerForMessageName:@"setKeyWindowContext" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	[messagingCenter registerForMessageName:@"setMissionControlActivated" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	[messagingCenter registerForMessageName:@"setMissionControlDeactivated" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	return self;
}


%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
	if([name isEqualToString:@"activate"]){
	
		BKApplication *application = [self applicationForBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"]];

		[application _activate:nil];
		//BKWorkspaceServer *server = [self workspaceForApplication:application];
	
		//[server _activate:application activationSettings:nil deactivationSettings:nil token:[objc_getClass("BKSWorkspaceActivationToken") token]];
	
	}else if([name isEqualToString:@"setApplicationPerformOriginals"]){
		BKApplication *application = [self applicationForBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"]];
		[application setPerformOriginals:[[userinfo objectForKey:@"performOriginals"] boolValue]];
		
	}else if([name isEqualToString:@"setKeyWindowContext"]){
		springBoardContext = [(NSNumber*)[userinfo objectForKey:@"context"] intValue];
	}else if([name isEqualToString:@"setMissionControlActivated"]){
		missionControlActive = true;
	}else if([name isEqualToString:@"setMissionControlDeactivated"]){
		missionControlActive = false;
	}

	return nil;
}

- (unsigned int)currentEventPort{
	return [self portForBundleIdentifier:@"com.apple.springboard"];
}
%end





static CPDistributedNotificationCenter *center;

%hook BKWorkspaceServer

- (id)init{
	self = %orig;

	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  	[nc addObserver:self
        selector:@selector(clientDidStartListening:)
        name:@"CPDistributedNotificationCenterClientDidStartListeningNotification"
        object:center
    ];

	return self;
}

%new
- (void)cancelAllTouches{
	[center postNotificationName:@"cancelTouches" userInfo:nil];
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

//Gesture fix
static BOOL OSGestureInProgress = false;
%hook CAWindowServerDisplay

- (unsigned int)contextIdAtPosition:(CGPoint)arg1{
	if(OSGestureInProgress || missionControlActive){
		return springBoardContext;
	}else{
		return %orig;
	}
}
%end

%end
//End (gesture fix)

%group other

static BOOL networkActivity;

%hook UIApplication

- (id)init{
	self = %orig;

	CPDistributedNotificationCenter* notificationCenter = [CPDistributedNotificationCenter centerNamed:notificationCenterID];
	[notificationCenter startDeliveringNotificationsToMainThread];
 
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
       	selector:@selector(notificationRecieved:)
        name:@"cancelTouches"
        object:notificationCenter
    ];

	return self;
}

%new
- (void)notificationRecieved:(NSNotification *)notification {
		[UIApp _cancelAllTouches];
}

- (BOOL)isNetworkActivityIndicatorVisible{
	return networkActivity;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)arg1{
	networkActivity = arg1;

	UIStatusBarData data = *[UIStatusBarServer getStatusBarData];
	data.itemIsEnabled[22] = arg1;
	[[UIApp statusBar] forceUpdateToData:&data animated:true];
}

%end

%hook UIStatusBar
- (void)statusBarServer:(id)arg1 didReceiveStatusBarData:(UIStatusBarData *)arg2 withActions:(int)arg3{
	arg2->itemIsEnabled[22] = networkActivity;
	%orig;
}
%end

%end

__attribute__((constructor))
static void initialize() {
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.backboardd"]){
		%init(Backboard);

		center = [CPDistributedNotificationCenter centerNamed:notificationCenterID];
  		[center runServer];
  		[center retain];
	}else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]){
		%init(SpringBoard);
		MSHookFunction(&SecTaskCopyValueForEntitlement, &$SecTaskCopyValueForEntitlement, &_SecTaskCopyValueForEntitlement);
	}else{
		%init(other);
	}
	
}
