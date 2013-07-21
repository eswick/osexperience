#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "launchpad/UIImage+StackBlur.h"
#import <mach/mach_time.h>










%group SpringBoard //Springboard hooks


%hook SBUIController


- (BOOL)activateSwitcher{

	if([[OSViewController sharedInstance] missionControlIsActive])
		[[OSViewController sharedInstance] setMissionControlActive:false animated:true];
	else
		[[OSViewController sharedInstance] setMissionControlActive:true animated:true];
	

	return true;
}




static char osViewKey;

-(BOOL)clickedMenuButton{
    [[OSViewController sharedInstance] menuButtonPressed];
   
    return true;
}


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

	//[UIApp.keyWindow addSubview:viewController.view];
	[UIApp.keyWindow setRootViewController:viewController];
	[viewController.view setFrame:[[UIScreen mainScreen] bounds]];

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

	
	
	[[OSSlider sharedInstance] setPageIndexPlaceholder:[[OSSlider sharedInstance] currentPageIndex]];

	[UIView animateWithDuration:arg3
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{

						UIView *osView = [self osView];
						osView.transform = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
						[osView setFrame:[[UIScreen mainScreen] bounds]];

						[[objc_getClass("SBIconController") sharedInstance] willAnimateRotationToInterfaceOrientation:arg2 duration:arg3];

                     } 
                     completion:^(BOOL finished){
                     }];

	[[OSSlider sharedInstance] willRotateToInterfaceOrientation:arg2 duration:arg3];
	[[OSThumbnailView sharedInstance] willRotateToInterfaceOrientation:arg2 duration:arg3];


	[[objc_getClass("SBIconController") sharedInstance] prepareToRotateFolderAndSlidingViewsToOrientation:arg2];
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

	%orig;
}

%end



//Background process handling





%hook SBApplication


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


- (void)didDeactivateForEventsOnly:(BOOL)arg1{

}

-(void)didSuspend{
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

%end



%hook SBIconController


-(void)iconWasTapped:(SBApplicationIcon*)arg1{
	[arg1 launchFromViewSwitcher];


	for(OSAppPane *pane in [[OSSlider sharedInstance] subviews]){
		if(![pane isKindOfClass:[OSAppPane class]])
			continue;

		if(pane.application == arg1.application){

			[UIView animateWithDuration:1.0 delay:0.25 options: UIViewAnimationCurveEaseOut animations:^{//Animate to activating app
				CGRect bounds = [[OSSlider sharedInstance] bounds];
                bounds.origin.x = pane.frame.origin.x;
                [[OSSlider sharedInstance] setBounds:bounds];
                [[OSSlider sharedInstance] updateDockPosition];
            }completion:^(BOOL finished){
         
            }];

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

- (void)animationDidStop:(id)arg1 finished:(id)arg2 context:(void *)arg3{
	%orig;
}


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

	return self;
}


%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
	if(![name isEqualToString:@"activate"]){
		return nil;
	}

	BKApplication *application = [self applicationForBundleIdentifier:[userinfo objectForKey:@"bundleIdentifier"]];

	BKWorkspaceServer *server = [self workspaceForApplication:application];
	
	[server _activate:application activationSettings:nil deactivationSettings:nil token:[objc_getClass("BKSWorkspaceActivationToken") token]];
	
	return nil;
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

%end



__attribute__((constructor))
static void initialize() {
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.backboardd"])
		%init(Backboard);
	

	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		%init(SpringBoard);
	
}
