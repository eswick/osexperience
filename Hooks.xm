#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "launchpad/UIImage+StackBlur.h"
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


/*----- Icon to open file explorer ----*/
%subclass OSExplorerIcon : SBIcon

- (id)displayName{
	return explorerIconDisplayName;
}

- (id)leafIdentifier{
	return explorerIconIdentifier;
}

- (BOOL)isLeafIcon{
	return true;
}

- (NSString*)representation{
	return explorerIconIdentifier;
}

- (void)launch{
	OSExplorerWindow *window = [[OSExplorerWindow alloc] init];
	OSDesktopPane *desktopPane = [[OSPaneModel sharedInstance] firstDesktopPane];

	[desktopPane addSubview:window];
	window.center = CGPointMake(desktopPane.bounds.size.width / 2, desktopPane.bounds.size.height / 2);
	[window release];
}

- (void)launchFromViewSwitcher{
	[self launch];
}

%end

%hook SBIconModel

- (void)loadAllIcons{
	%orig;
	OSExplorerIcon *explorerIcon = [[%c(OSExplorerIcon) alloc] init];
	[self addIcon:explorerIcon];
	[explorerIcon release];
	return;
}

%end

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
	if([[%c(SBAwayController) sharedAwayController] isLocked])
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
		[arg1 launchFromViewSwitcher];
	}else{
		[[arg1 application] addToSlider];
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

		BKWorkspaceServer *server = [self workspaceForApplication:application];
	
		[server _activate:application activationSettings:nil deactivationSettings:nil token:[objc_getClass("BKSWorkspaceActivationToken") token]];
	
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

static IOHIDEventSystemCallback eventCallback = NULL;

void resetTouches(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event){
	IOHIDEventRef eventNegator = IOHIDEventCreateCopy(kCFAllocatorDefault, event);

	CFArrayRef children = IOHIDEventGetChildren(eventNegator);

	for(int i = 0; i < CFArrayGetCount(children); i++){
		IOHIDEventSetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerTouch, 0);
		IOHIDEventSetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerRange, 0);
		IOHIDEventSetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerEventMask, 3);
	}

	eventCallback(target, refcon, service, eventNegator);

	for(int i = 0; i < CFArrayGetCount(children); i++){
		IOHIDEventSetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerTouch, 1);
		IOHIDEventSetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerRange, 1);
		IOHIDEventSetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerEventMask, 3);
	}

	eventCallback(target, refcon, service, eventNegator);

	CFRelease(eventNegator);
}

void handle_event (void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event) {
	if(IOHIDEventGetType(event) == kIOHIDEventTypeDigitizer){
		CFArrayRef children = IOHIDEventGetChildren(event);

		if(children != NULL){
			int count = 0;

			for(int i = 0; i < CFArrayGetCount(children); i++){
				int value = IOHIDEventGetIntegerValue((IOHIDEventRef)CFArrayGetValueAtIndex(children, i), kIOHIDEventFieldDigitizerTouch);
				if(value == 1)
					count++;
			}

			if(count >= 4){
				if(!OSGestureInProgress == true){
					OSGestureInProgress = true;
					[[[%c(BKWorkspaceServerManager) sharedInstance] currentWorkspace] cancelAllTouches];
					resetTouches(target, refcon, service, event);
					return;
				}
			}else if(count == 0){
				OSGestureInProgress = false;
			}
		}
	}
	eventCallback(target, refcon, service, event);
}

MSHook(Boolean, IOHIDEventSystemOpen, IOHIDEventSystemRef system, IOHIDEventSystemCallback callback, void* target, void* refcon, void* unused){
	eventCallback = callback;
	return _IOHIDEventSystemOpen(system, handle_event, target, refcon, unused);
}

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
		MSHookFunction(&IOHIDEventSystemOpen, MSHake(IOHIDEventSystemOpen));

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
