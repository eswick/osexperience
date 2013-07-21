#define UIApp [UIApplication sharedApplication]
#define DegreesToRadians(x) ((x) * M_PI / 180.0)



@interface BKProcess{

}

-(void)killWithSignal:(int)arg1;


@end






@interface BKApplication : NSObject{

}

-(int)suspendType;
-(void)setSuspendType:(int)arg1;
//- (id)initWithBundleIdentifier:(id)arg1 queue:(dispatch_queue_s*)arg2;

@end

@interface SBFakeStatusBarView : UIView



@end


@interface UIEvent(OSAdditions)

-(struct __GSEvent*)_gsEvent;

@end


@interface UITouchesEvent : NSObject


- (id)allTouches;
- (struct __GSEvent*)_gsEvent;


@end


@interface UIStatusBar : UIView

+ (int)defaultStatusBarStyleWithTint:(BOOL)arg1;
+ (CGRect)frameForStyle:(int)arg1 orientation:(int)arg2;

@end



@interface SBApplication : NSObject {

}

- (id)displayIdentifier;
- (id)displayValue:(int)arg1;
- (int)contextID;
- (void)setContextID:(int)arg1;
- (id)displayName;
- (id)contextHostViewForRequester:(id)arg1 enableAndOrderFront:(BOOL)arg2;
- (id)bundleIdentifier;
- (void)activate; //New (Added functionality back; Original function simply returns.)
- (BOOL)activationFlag:(unsigned int)arg1;
- (void)addToSlider; //New
- (unsigned int)eventPort;
- (void)rotateToInterfaceOrientation:(int)orientation;//New


@end




@interface SBWorkspace : NSObject

-(void)setCurrentTransaction:(id)arg1;

@end


@interface UITouch(FixAdditions)


- (void)_loadStateFromTouch:(id)arg1;

@end

@interface UITouchesEvent(FixAdditions)


-(void)_addTouch:(id)touch forDelayedDelivery:(BOOL)delayedDelivery;
-(void)_removeTouch:(id)touch;

@end



@interface CPDistributedMessagingCenter : NSObject
{

}

+ (id)centerNamed:(id)arg1;

- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (void)stopServer;
- (void)runServerOnCurrentThread;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2 error:(id *)arg3;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;

@end


@interface SBIconController

+ (id)sharedInstance;
- (void)prepareToRotateFolderAndSlidingViewsToOrientation:(int)arg1;
- (id)dock;
- (id)contentView;
- (BOOL)hasOpenFolder;
- (void)_showSearchKeyboardIfNecessary:(BOOL)arg1;
- (BOOL)isShowingSearch;

@end


@interface SBDockIconListView : UIView


@end

@interface SBUIAnimationZoomUpApp

- (void)_noteAnimationDidFinish:(BOOL)arg1;
- (void)animationDidStop:(id)arg1 finished:(id)arg2 context:(void *)arg3;
- (void)_cleanupAnimation;

@end 

@interface SBApplicationIcon : NSObject


-(void)launch;
-(void)launchFromViewSwitcher;
-(SBApplication*)application;
- (id)initWithApplication:(id)arg1;

@end

@interface SBAppToAppTransitionController


-(SBApplication*)activatingApp;
- (void)_cleanupAnimation;
- (void)_cancelAnimation;
- (void)appTransitionViewAnimationDidStop:(id)arg1;

@end




@interface SBIcon : NSObject


- (BOOL)isFolderIcon;
- (BOOL)isNewsstandIcon;
- (void)launch;
- (id)generateIconImage:(int)arg1;
- (id)getIconImage:(int)arg1;


@end


@interface SBIconView : UIImageView

- (SBIcon*)icon;
- (id)iconImageView;
- (BOOL)isGrabbed;
- (BOOL)isInDock;


@end






@interface SBHostWrapperView : UIView



@end

@interface BKWorkspaceServerManager

-(id)applicationForBundleIdentifier:(NSString*)bundleIdentifier;
-(id)workspaceForApplication:(id)application;
-(id)currentWorkspace;

@end


@interface BKWorkspaceServer

-(void)activate:(id)arg1 withActivation:(id)arg2 withDeactivation:(id)arg3 token:(id)arg4;
- (BOOL)_activate:(id)arg1 activationSettings:(id)arg2 deactivationSettings:(id)arg3 token:(id)arg4;

@end

@interface BKSWorkspaceActivationToken

+(id)token;

@end


@interface SBApplicationController{

}

+(id)sharedInstance;

-(id)applicationWithDisplayIdentifier:(NSString*)arg1;

@end

@interface BKSApplicationProcessInfo

-(BOOL)suspended;
-(id)bundleIdentifier;

@end

@interface UIApplication(OSAdditions)
-(id)displayIdentifier;


@end



@interface UIWindow(OSAdditions)

-(unsigned int)_contextId;

@end



@interface SBUIController : UIView{

}

+ (id)sharedInstance;
+ (id)zoomViewForContextHostView:(id)arg1 application:(id)arg2 includeStatusBar:(BOOL)arg3 includeBanner:(BOOL)arg4;

- (id)osView;//New
- (void)setOSView:(id)arg1;//New

- (id)wallpaperView;
- (id)rootView;
- (void)activateApplicationAnimated:(id)arg1;
- (id)systemGestureSnapshotWithIOSurfaceSnapshotOfApp:(id)arg1 includeStatusBar:(BOOL)arg2;
- (id)systemGestureSnapshotForApp:(id)arg1 includeStatusBar:(BOOL)arg2 decodeImage:(BOOL)arg3;


@end


@interface SBFluidSlideGestureRecognizer : NSObject

-(float)cumulativePercentage;
-(CGPoint)centroidPoint;


@end
