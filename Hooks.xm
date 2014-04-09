#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import <mach/mach_time.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <substrate.h>
#import "explorer/OSExplorerWindow.h"
#import <rocketbootstrap.h>


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

%property (assign) BOOL switchAppGestureInProgress;
%property (assign) BOOL switcherGestureInProgress;
%property (assign) BOOL scaleGestureInProgress;

- (UIView*)contentView{
	return [[OSViewController sharedInstance] iconContentView];
}

- (BOOL)allowSystemGestureType:(SBSystemGestureType)type atLocation:(struct CGPoint)arg2{
	
	if(type & SBSystemGestureTypeSuspendApp){
		if(self.switchAppGestureInProgress || self.switcherGestureInProgress || [[OSViewController sharedInstance] missionControlIsActive])
			return false;
	}

	if(type & SBSystemGestureTypeSwitcher){
		if(self.switchAppGestureInProgress || self.scaleGestureInProgress)
			return false;
	}

	if(type & SBSystemGestureTypeSwitchApp){
		if(self.scaleGestureInProgress || self.switcherGestureInProgress || [[OSViewController sharedInstance] missionControlIsActive])
			return false;
	}

	return %orig;
}

- (void)handleFluidVerticalSystemGesture:(SBPanGestureRecognizer*)arg1{

	static BOOL upGestureWasRecognized = false;
	static BOOL downGestureWasRecognized = false;

	if([arg1 state] == UIGestureRecognizerStateBegan)
		self.switcherGestureInProgress = true;

	if([arg1 state] == UIGestureRecognizerStateEnded || [arg1 state] == UIGestureRecognizerStateCancelled){
		upGestureWasRecognized = false;
		downGestureWasRecognized = false;

		self.switcherGestureInProgress = false;
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

- (void)handleFluidScaleSystemGesture:(SBScaleGestureRecognizer*)arg1{

	static BOOL launchpadClosing = false;

	float percentage = [arg1 cumulativeMotion] / [arg1 animationDistance];

	if([arg1 state] == UIGestureRecognizerStateBegan){
		self.scaleGestureInProgress = true;
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
		[[OSViewController sharedInstance] setLaunchpadAnimating:true];

		if([arg1 completionTypeProjectingMomentumForInterval:3.0] != -1){
			if(!launchpadClosing){
				[UIView animateWithDuration:0.25
					delay:0
					options: UIViewAnimationOptionCurveEaseOut
					animations:^{
						[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:1];
						[[OSViewController sharedInstance] setDockPercentage:0.0];
					}completion:^(BOOL completed){
						self.scaleGestureInProgress = false;
						[[OSViewController sharedInstance] setLaunchpadActive:true];
						[[OSViewController sharedInstance] setLaunchpadAnimating:false];
					}];
			}else{
				[UIView animateWithDuration:0.25
					delay:0
					options: UIViewAnimationOptionCurveEaseOut 
					animations:^{
						self.scaleGestureInProgress = false;
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
					self.scaleGestureInProgress = false;
					[[OSSlider sharedInstance] updateDockPosition];
					[[OSViewController sharedInstance] setLaunchpadVisiblePercentage:0];
				}completion:^(BOOL completed){
					[[OSViewController sharedInstance] setLaunchpadActive:false];
					[[OSViewController sharedInstance] setLaunchpadAnimating:false];
				}];
		}
	}else if([arg1 state] == UIGestureRecognizerStateCancelled){
		self.scaleGestureInProgress = false;
	}
}

- (void)_switchAppGestureBegan:(double)arg1{
	for(UIGestureRecognizer *recognizer in [[OSSlider sharedInstance] gestureRecognizers]){
		if([recognizer isKindOfClass:objc_getClass("UIScrollViewPagingSwipeGestureRecognizer")]){
			recognizer.enabled = false;
		}
	}

	self.switchAppGestureInProgress = true;

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
	self.switchAppGestureInProgress = false;

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

static BOOL preventSwitcherDismiss = false;
- (void)dismissSwitcherAnimated:(BOOL)arg1{
	if(!preventSwitcherDismiss)
		[[OSViewController sharedInstance] setMissionControlActive:false animated:arg1];
}

- (void)activateApplicationAnimated:(id)arg1{
	preventSwitcherDismiss = true;
	%orig;
	preventSwitcherDismiss = false;
}

- (void)_toggleSwitcher{

	if([[OSViewController sharedInstance] missionControlIsActive])
		[[OSViewController sharedInstance] setMissionControlActive:false animated:true];
	else
		[[OSViewController sharedInstance] setMissionControlActive:true animated:true];
}


-(id)init{
	self = %orig;

	[MSHookIvar<UIView*>(self, "_contentView") removeFromSuperview];

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
	}completion:^(BOOL finished){

    }];

	[[OSSlider sharedInstance] willRotateToInterfaceOrientation:arg2 duration:arg3];
	[[OSThumbnailView sharedInstance] willRotateToInterfaceOrientation:arg2 duration:arg3];

	%orig;

	[[OSSlider sharedInstance] updateDockPosition];
}

- (BOOL)hasPendingAppActivatedByGesture{
	return true;
}

%end

%hook SBIconListView

- (void)prepareToRotateToInterfaceOrientation:(UIInterfaceOrientation)arg1{
	self.transform = CGAffineTransformIdentity;
	%orig;
}

%end

%hook SpringBoard

- (id)_accessibilityFrontMostApplication{
	return nil;
}

- (void)sendEvent:(id)arg1{

	GSEventRef event = [arg1 _gsEvent];

	if(event == NULL){
		%orig; return;
	}

	if(GSEventGetType(event) == kGSEventDeviceOrientationChanged){
		for(OSAppPane *appPane in [[OSPaneModel sharedInstance] panes]){
			if(![appPane isKindOfClass:[OSAppPane class]])
				continue;

			[[appPane application] rotateToInterfaceOrientation:GSEventDeviceOrientation(event)];
		}
	}

	/*if(GSEventGetType(event) == kGSEventKeyUp || GSEventGetType(event) == kGSEventKeyDown){
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
	}*/

	%orig;
}

- (void)_handleMenuButtonEvent{
	

	if([[%c(SBNotificationCenterController) sharedInstance] isVisible]){
		[[%c(SBNotificationCenterController) sharedInstance] dismissAnimated:true];
		return;
	}

	if([%c(SBAssistantController) isAssistantVisible]){
		SBAssistantController *controller = [%c(SBAssistantController) sharedInstanceIfExists];
		[controller _dismissForMainScreenAnimated:true duration:[controller _defaultAnimatedDismissDurationForMainScreen] completion:nil];
		return;
	}

	if([UIApp isLocked])
		return;

	if([[OSViewController sharedInstance] launchpadIsActive])
		[[OSViewController sharedInstance] setLaunchpadActive:false animated:true];
	else
		[[OSViewController sharedInstance] setLaunchpadActive:true animated:true];
}

- (void)applicationDidFinishLaunching:(id)arg1{
	%orig;

	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.springboardserver"];
	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
	[messagingCenter runServerOnCurrentThread];
	[messagingCenter registerForMessageName:@"forceClassic" target:self selector:@selector(handleMessageNamed:withUserInfo:)]; 
	[messagingCenter registerForMessageName:@"checkin" target:self selector:@selector(handleMessageNamed:withUserInfo:)]; 
}

%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
	if([name isEqualToString:@"checkin"])
		return @{};

	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:[userinfo objectForKey:@"bundleID"]];

	if([app forceClassic]){
		return @{@"forceClassic" : @(true)};
	}else{
		return @{@"forceClassic" : @(false)};
	}
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
					dispatch_async(dispatch_get_main_queue(), ^{
						[pane bringSubviewToFront:window];
						[pane setActiveWindow:window];
					});
				}
			}
		}
	}

	%orig;
}
%end

%hook SBWindowContextHostManager

- (id)hostViewForRequester:(id)arg1 enableAndOrderFront:(_Bool)arg2{
	if([arg1 isEqualToString:@"com.apple.springboard.launchwithzoomanimation"])
		return nil;
	return %orig;
}

%end

%hook SBApplication

%property (assign) BOOL forceClassic;
%property (assign, getter=isRelaunching) BOOL relaunching;

- (void)setDisplaySetting:(unsigned int)arg1 value:(id)arg2{
	%orig;
	if(arg1 == 4){//Rotation changed
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
		for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
			[thumbnail layoutSubviews];
		}
	}
}

-(void)didExitWithInfo:(id)arg1 type:(int)arg2{

	if([self isRelaunching]){
		%orig;
		[self performSelector:@selector(launch) withObject:nil afterDelay:1];
		return;
	}

	OSAppPane *appPane = nil;

	for(OSAppPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == self)
			appPane = pane;
	}

	OSAppWindow *foundWindow = nil;
	OSDesktopPane *foundDesktop = nil;

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
					foundDesktop = desktop;
					foundWindow = window;
				}
			}

		}
	}

	[foundDesktop.windows removeObject:foundWindow];
	[foundWindow removeFromSuperview];

    %orig;
}


-(void)didSuspend{
	return;

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
- (BOOL)rotateToInterfaceOrientation:(int)orientation{

	struct GSOrientationEvent {
		GSEventRecord record;
		GSDeviceOrientationInfo orientationInfo;
	} event;

	bzero(&event, sizeof(event));

	event.record.type = kGSEventDeviceOrientationChanged;
	event.record.flags = (GSEventFlags)0;
	event.record.infoSize = 4;
	event.orientationInfo.orientation = orientation;

	int success = GSSendEvent((GSEventRecord*)&event, (mach_port_t)[self eventPort]);

	return (success == 0);
}

-(void)willActivate{
	%orig;
	[self addToSlider];
}

- (void)didLaunch:(BKSApplicationProcessInfo*)arg1{
	if([self isRelaunching])
		[self setRelaunching:false];

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
			[foundWindow resetHostView];
			[[OSSlider sharedInstance] scrollToPane:[[OSPaneModel sharedInstance] desktopPaneContainingWindow:foundWindow] animated:true];
		}
	}

}

- (void)activate{
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageName:@"activate" userInfo:dictionary];
}



%new
- (void)suspend{
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);

	NSArray *keys = [NSArray arrayWithObjects:@"bundleIdentifier", @"performOriginals", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self displayIdentifier], [NSNumber numberWithBool:true], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	[messagingCenter sendMessageAndReceiveReplyName:@"setApplicationPerformOriginals" userInfo:dictionary];


	BKSTerminateApplicationForReasonAndReportWithDescription([self bundleIdentifier], 3, 0, 0);

}

%new
- (void)relaunch{
	[self setRelaunching:true];
	[self suspend];
}

%new
- (void)launch{
	SBIconModel *iconModel = MSHookIvar<SBIconModel*>([%c(SBIconController) sharedInstance], "_iconModel");
	SBIcon *icon = [iconModel applicationIconForDisplayIdentifier:[self bundleIdentifier]];

	[self icon:icon launchFromLocation:0];
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

%hook SBToAppWorkspaceTransaction

- (void)performToAppStateCleanup{
	preventSwitcherDismiss = true;
	%orig;
	preventSwitcherDismiss = false;
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

- (void)willRotateToInterfaceOrientation:(long long)arg1 duration:(double)arg2{
	[[[OSViewController sharedInstance] iconContentView] contentView].transform = CGAffineTransformIdentity;
	%orig;
}

%end

/* Block app launch animation */

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


	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];
	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);

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

		BKWorkspaceServer *server = [self workspaceForApplication:application];
		[server _activate:application activationSettings:nil deactivationSettings:nil token:[[%c(BKSWorkspaceActivationTokenFactory) sharedInstance] generateToken] completion:nil];
	
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

%property (assign) BOOL performOriginals;

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

BOOL checkin_with_springboard(){
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.springboardserver"];
	NSDictionary *response = [messagingCenter sendMessageAndReceiveReplyName:@"checkin" userInfo:nil];

	if(response)
		return true;
	else
		return false;
}

//Gesture fix
static BOOL OSGestureInProgress = false;
%hook CAWindowServerDisplay

- (unsigned int)contextIdAtPosition:(CGPoint)arg1{
	if(!checkin_with_springboard())
		return %orig;

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

	return self;
}

- (BOOL)_isClassic{
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.springboardserver"];

	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);

	NSArray *keys = [NSArray arrayWithObjects:@"bundleID", nil];
	NSArray *objects = [NSArray arrayWithObjects:[[NSBundle mainBundle] bundleIdentifier], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	NSDictionary *response = [messagingCenter sendMessageAndReceiveReplyName:@"forceClassic" userInfo:dictionary];

	if([[response objectForKey:@"forceClassic"] boolValue]){
		return true;
	}

	return %orig;
}

- (BOOL)_shouldZoom{
	return true;
}

- (BOOL)isNetworkActivityIndicatorVisible{
	return networkActivity;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)arg1{
	networkActivity = arg1;

	UIStatusBarData data = *[UIStatusBarServer getStatusBarData];
	data.networkActivity = arg1;
	[[UIApp statusBar] forceUpdateToData:&data animated:true];
}

%end

%hook UIDevice

- (UIUserInterfaceIdiom)userInterfaceIdiom{
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.springboardserver"];

	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);

	NSArray *keys = [NSArray arrayWithObjects:@"bundleID", nil];
	NSArray *objects = [NSArray arrayWithObjects:[[NSBundle mainBundle] bundleIdentifier], nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	NSDictionary *response = [messagingCenter sendMessageAndReceiveReplyName:@"forceClassic" userInfo:dictionary];
	return [[response objectForKey:@"forceClassic"] boolValue] ? UIUserInterfaceIdiomPhone : %orig;
}

%end

%hook UIStatusBar
- (void)statusBarServer:(id)arg1 didReceiveStatusBarData:(UIStatusBarData *)arg2 withActions:(int)arg3{
	arg2->networkActivity = networkActivity;
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
