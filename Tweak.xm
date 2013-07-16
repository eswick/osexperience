#import "include.h"
#import "OSViewController.h"
#import "OSAppPane.h"
#import <dispatch/dispatch.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "launchpad/UIImage+StackBlur.h"




@interface SBUIController(OSExtensions)

-(id)osView;
-(void)setOSView:(id)arg1;

@end





%hook SBUIController

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

	NSLog(@"View: %@", NSStringFromCGRect(viewController.view.frame));


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

	[[objc_getClass("SBIconController") sharedInstance] prepareToRotateFolderAndSlidingViewsToOrientation:arg2];
	[[objc_getClass("SBIconController") sharedInstance] willAnimateRotationToInterfaceOrientation:arg2 duration:arg3];
}


- (void)handleFluidVerticalSystemGesture:(id)arg1{

}

- (void)handleFluidHorizontalSystemGesture:(id)arg1{
	//%orig;
}


- (void)_switchAppGestureCancelled{}
- (void)_switchAppGestureEndedWithCompletionType:(int)arg1 cumulativePercentage:(float)arg2{}
- (void)_switchAppGestureChanged:(float)arg1{}
- (void)_switchAppGestureBegan:(float)arg1{}


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

	BKWorkspaceServer *server = [self workspaceForApplication:application];
	
	[server _activate:application activationSettings:nil deactivationSettings:nil token:[objc_getClass("BKSWorkspaceActivationToken") token]];
	
	return nil;
}


%end


%hook SBApplication


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
			[[OSSlider sharedInstance] setContentOffset:CGPointMake(pane.frame.origin.x, 0) animated:true];
		}
	}


}


-(void)iconTapped:(SBIconView*)arg1{
    if(![[OSViewController sharedInstance] launchpadActive]){
        %orig;
        return;
    }
    
    if([[arg1 icon] isFolderIcon] || [[arg1 icon] isNewsstandIcon]){
        [[arg1 icon] launch];
    }else{
        [[OSViewController sharedInstance] deactivateWithIconView:arg1];
        %orig;
    }

}


%end


%hook BKSWorkspace

- (id)topApplication{
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


