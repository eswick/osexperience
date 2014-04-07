#define UIApp ((SpringBoard*)[UIApplication sharedApplication])
#define DegreesToRadians(x) ((x) * M_PI / 180.0)

#import <QuartzCore/QuartzCore.h>

@interface SBIcon : NSObject


- (BOOL)isFolderIcon;
- (BOOL)isNewsstandIcon;
- (void)launchFromLocation:(int)arg1;
- (id)generateIconImage:(int)arg1;
- (id)getIconImage:(int)arg1;


@end

@interface UIScrollView()

- (void)_endPanNormal:(BOOL)arg1;
- (struct CGPoint)_pageDecelerationTarget;
- (void)_prepareToPageWithHorizontalVelocity:(double)arg1 verticalVelocity:(double)arg2;
- (struct CGPoint)_rubberBandContentOffsetForOffset:(struct CGPoint)arg1 outsideX:(BOOL *)arg2 outsideY:(BOOL *)arg3;


@end

@interface OSExplorerIcon : SBIcon

@end

@interface SBApplicationIcon : NSObject
{
    NSString *_displayIdentifier;
    unsigned int _appIsBeingCleaned:1;
}

- (id)applicationBundleID;
- (id)folderFallbackTitle;
- (id)folderTitleOptions;
- (void)setBadge:(id)arg1;
- (void)launchFromViewSwitcher;
- (void)launch;
- (void)_terminationAssertionDidChange;
- (void)_setAppIsBeingCleanedFlag;
- (BOOL)launchEnabled;
- (id)automationID;
- (id)tags;
- (BOOL)canEllipsizeLabel;
- (id)displayName;
- (id)generateIconImage:(int)arg1;
- (BOOL)canGenerateImageInBackgroundForFormat:(int)arg1;
- (void)generateIconImageInBackground:(id)arg1;
- (id)blockForGeneratingIconImageInBackgroundWithFormat:(SEL)arg1;
- (id)_blockForGeneratingIconImageInBackgroundWithFormat:(SEL)arg1 complete:(int)arg2;
- (id)__loadIconImage:(id)arg1 format:(int)arg2 scale:(float)arg3;
- (void)completeUninstall;
- (id)application;
- (void)dealloc;
- (id)initWithApplication:(id)arg1;

@end

@interface SBIconModel : NSObject

- (void)addIcon:(SBIcon *)arg1;
- (id)applicationIconForDisplayIdentifier:(id)arg1;

@end

@interface SBAppContextHostManager : NSObject

- (CGImageRef)createIOSurfaceForFrame:(struct CGRect)arg1;
- (CGImageRef)createIOSurfaceForFrame:(struct CGRect)arg1 outTransform:(CGAffineTransform*)arg2;

@end

@interface SBAppContextHostView : UIView

- (id)manager;

@end

@interface CPDistributedNotificationCenter : NSObject  {
    NSString *_centerName;
    NSLock *_lock;
    struct __CFRunLoopSource { } *_receiveNotificationSource;
    BOOL _isServer;
    struct __CFDictionary { } *_sendPorts;
    unsigned int _startCount;
}

+ (id)centerNamed:(id)arg1;

- (id)name;
- (void)dealloc;
- (void)stopDeliveringNotifications;
- (void)_notificationServerWasRestarted;
- (void)deliverNotification:(id)arg1 userInfo:(id)arg2;
- (void)_checkIn;
- (void)_checkOutAndRemoveSource;
- (id)_initWithServerName:(id)arg1;
- (void)runServer;
- (void)runServerOnCurrentThread;
- (void)postNotificationName:(id)arg1;
- (BOOL)postNotificationName:(id)arg1 userInfo:(id)arg2 toBundleIdentifier:(id)arg3;
- (void)postNotificationName:(id)arg1 userInfo:(id)arg2;
- (void)startDeliveringNotificationsToMainThread;
@end

typedef struct { 
    union{
        BOOL itemIsEnabled[25];
        struct{
            BOOL time;
            BOOL doNotDisturb;
            BOOL airplaneMode;
            BOOL signalBars;
            BOOL serviceStringEnabled;
            BOOL wifiBars;
            BOOL unk_000;
            BOOL battery;
            BOOL batteryPercentage;
            BOOL unk_001;
            BOOL weirdBatteryIcon;
            BOOL bluetooth;
            BOOL phoneAboveKeyboard;
            BOOL alarm;
            BOOL plus;
            BOOL playing;
            BOOL locationServices;
            BOOL orientationLock;
            BOOL unk_002;
            BOOL airPlay;
            BOOL microphone;
            BOOL vpn;
            BOOL phoneWithArrow;
            BOOL networkActivity;
            BOOL unk_003;
        };
    };
    /*
	0 - Time
	1 - Do Not Disturb
	2 - Airplane Mode
	3 - Signal Bars
	4 - Service String
	5 - Wifi Bars
	6 - Time (2nd?)
	7 - Battery icon
	8 - Battery percentage
	9 - Second battery percentage?
	10 - Weird rectangular icon. (maybe a battery?)
	11 - Bluetooth
	12 - Phone above keyboard?
	13 - Alarm
	14 - Plus
	15 - Playing
	16 - Location Services
	17 - Orientation Lock
	18 - Unknown
	19 - AirPlay
	20 - Microphone
	21 - VPN
	22 - Phone with right-facing arrow
	23 - Activity
    24 - Empty space?

    */
    char timeString[64];
    int gsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    char serviceString[100];
    char serviceCrossfadeString[100];
    char serviceImages[2][100];
    char operatorDirectory[1024];
    unsigned int serviceContentType;
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned int dataNetworkType;
    int batteryCapacity;
    unsigned int batteryState;
    char batteryDetailString[150];
    int bluetoothBatteryCapacity;
    int thermalColor;
    unsigned int thermalSunlightMode:1;
    unsigned int slowActivity:1;
    unsigned int syncActivity:1;
    char activityDisplayId[256];
    unsigned int bluetoothConnected:1;
    unsigned int displayRawGSMSignal:1;
    unsigned int displayRawWifiSignal:1;
    unsigned int locationIconType:1;
    unsigned int quietModeInactive:1;
    unsigned int tetheringConnectionCount;
} UIStatusBarData;

typedef struct{
    char overrideItemIsEnabled[24];
    unsigned int overrideTimeString:1;
    unsigned int overrideGsmSignalStrengthRaw:1;
    unsigned int overrideGsmSignalStrengthBars:1;
    unsigned int overrideServiceString:1;
    unsigned int overrideServiceImages:2;
    unsigned int overrideOperatorDirectory:1;
    unsigned int overrideServiceContentType:1;
    unsigned int overrideWifiSignalStrengthRaw:1;
    unsigned int overrideWifiSignalStrengthBars:1;
    unsigned int overrideDataNetworkType:1;
    unsigned int disallowsCellularDataNetworkTypes:1;
    unsigned int overrideBatteryCapacity:1;
    unsigned int overrideBatteryState:1;
    unsigned int overrideBatteryDetailString:1;
    unsigned int overrideBluetoothBatteryCapacity:1;
    unsigned int overrideThermalColor:1;
    unsigned int overrideSlowActivity:1;
    unsigned int overrideActivityDisplayId:1;
    unsigned int overrideBluetoothConnected:1;
    unsigned int overrideDisplayRawGSMSignal:1;
    unsigned int overrideDisplayRawWifiSignal:1;
    UIStatusBarData values;
} UIStatusBarOverrideData;


@class SBProxyRemoteView;
@protocol SBProxyRemoteViewDelegate <NSObject>

- (void)remoteViewDidConnect:(SBProxyRemoteView*)remoteView;
- (void)remoteViewDidDisconnect:(SBProxyRemoteView*)remoteView;

@end

@interface SBProxyRemoteView : UIView

@property(nonatomic) BOOL remoteViewOpaque; // @synthesize remoteViewOpaque=_remoteViewOpaque;
@property(nonatomic, assign) id<SBProxyRemoteViewDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) NSString *remoteViewIdentifier; // @synthesize remoteViewIdentifier=_remoteViewIdentifier;
- (void)disconnect;
- (void)noteConnectionLost;
- (void)_setIsConnected:(BOOL)arg1;
- (void)connectToContextID:(unsigned int)arg1 forIdentifier:(id)arg2 application:(id)arg3;
- (void)didMoveToSuperview;

@end

@interface SBAwayController : NSObject

+ (id)sharedAwayController;
- (BOOL)isLocked;

@end

@interface SBGestureRecognizer : NSObject

@property(nonatomic) int state;
@property(copy, nonatomic) id handler;

- (int)templateMatch;

@end

@interface SBFluidSlideGestureRecognizer : SBGestureRecognizer

@property(readonly, nonatomic) struct CGPoint movementVelocityInPointsPerSecond;
@property(readonly, nonatomic) float cumulativePercentage;
@property(readonly, nonatomic) double activeRecognitionDuration;
@property(readonly, nonatomic) double incrementalMotion;
@property(readonly, nonatomic) double cumulativeMotion;
@property(readonly, nonatomic) double skippedCumulativePercentage;
@property(nonatomic) double animationDistance;

- (void)updateForBeganOrMovedTouches:(void*)arg1;
- (float)computeIncrementalGestureMotion:(void*)arg1;
- (long long)completionTypeProjectingMomentumForInterval:(double)arg1;

@end

@interface SBPanGestureRecognizer : SBFluidSlideGestureRecognizer

@end

@interface SBScaleGestureRecognizer : SBFluidSlideGestureRecognizer
@end

@interface UIStatusBarServer : NSObject

+ (UIStatusBarData*) getStatusBarData;
+ (UIStatusBarOverrideData *)getStatusBarOverrideData;
+ (void)postStatusBarData:(UIStatusBarData *)arg1 withActions:(int)arg2;
+ (void)postStatusBarOverrideData:(UIStatusBarOverrideData *)arg1;

@end

typedef struct {
	int type;
	unsigned pathIndex;
	CGPoint location;
	CGPoint previousLocation;
	CGFloat totalDistanceTraveled;
	UIInterfaceOrientation interfaceOrientation;
	UIInterfaceOrientation previousInterfaceOrientation;
} SBGestureRecognizerTouchData;

@interface SBHandMotionExtractor

- (void)extractHandMotionForActiveTouches:(SBGestureRecognizerTouchData *)arg1 count:(unsigned int)arg2 centroid:(struct CGPoint)arg3;

@end


@interface BKProcess{

}

- (void)killWithSignal:(int)arg1;
- (BOOL)_suspend;
- (BOOL)performOriginals;//New
- (void)setPerformOriginals:(BOOL)arg1;//New


@end

@interface SBWallpaperView : UIImageView

- (void)setOrientation:(int)arg1 duration:(double)arg2;
- (void)setGradientAlpha:(float)arg1;
- (id)initWithOrientation:(NSUInteger)arg1 variant:(NSUInteger)arg2;

@end

@interface UIToolbar (STFUACAdditions)

- (UIView*)_backgroundView;

@end

@interface BKSSystemServices : NSObject

- (id)proxy:(id)arg1 detailedSignatureForSelector:(SEL)arg2;
- (void)terminateApplicationGroup:(int)arg1 forReason:(int)arg2 andReport:(BOOL)arg3 withDescription:(id)arg4;
- (void)terminateApplication:(id)arg1 forReason:(int)arg2 andReport:(BOOL)arg3 withDescription:(id)arg4;
- (void)dealloc;
- (id)init;

@end

@interface UIBarButtonItem (STFUACAdditions)

- (UIView*)view;

@end

@interface SpringBoard : UIApplication

- (UIWindow*)statusBarWindow;
- (UIWindow*)keyWindow;
- (void)clearMenuButtonTimer;
- (BOOL)isLocked;

@end

@interface SBWallpaperImage : UIImage

+ (id)cachedWallpaperDataForVariant:(long long)arg1;
- (id)initWithVariant:(long long)arg1;

@end

@interface SBFStaticWallpaperView : UIView

- (id)initWithFrame:(struct CGRect)arg1 wallpaperImage:(id)arg2;
- (void)_startGeneratingBlurredImages;

@end

@interface SBWallpaperController : NSObject

+ (id)sharedInstance;

- (id)_blurViewsForVariant:(NSUInteger)arg1;
- (id)_wallpaperViewForVariant:(NSUInteger)arg1;
- (id)_newFakeBlurViewForVariant:(NSUInteger)arg1;
- (id)initWithOrientation:(NSUInteger)arg1 variant:(NSUInteger)arg2;

@end

@interface BKApplication : NSObject

-(int)suspendType;
-(void)setSuspendType:(int)arg1;
- (BKProcess*)process;
- (BOOL)performOriginals;//New
- (void)setPerformOriginals:(BOOL)arg1;//New
- (void)_deactivate:(id)arg1;
- (NSString*)bundleIdentifier;
- (int)activationState;
- (void)_activate:(id)arg1;
- (unsigned int)eventPort;
//- (id)initWithBundleIdentifier:(id)arg1 queue:(dispatch_queue_s*)arg2;

@end



@interface SBFakeStatusBarView : UIView

- (void)requestStyle:(int)arg1;

@end


@interface UIEvent(STFUACAdditions)

-(struct __GSEvent*)_gsEvent;

@end

@interface SBWindowContextHostManager : NSObject

- (id)hostViewForRequester:(id)arg1 enableAndOrderFront:(BOOL)arg2;

@end

@interface SBWindowContextManager : NSObject

- (id)contextsForScreen:(UIScreen*)arg1;

@end

@interface SBWindowContext : NSObject

@property(readonly, nonatomic) unsigned int identifier;

@end

@interface UITouchesEvent : NSObject


- (id)allTouches;
- (struct __GSEvent*)_gsEvent;


@end


@interface UIStatusBar : UIView

+ (int)defaultStatusBarStyleWithTint:(BOOL)arg1;
+ (CGRect)frameForStyle:(int)arg1 orientation:(int)arg2;

- (void)setLocalDataOverrides:(UIStatusBarOverrideData *)arg1;
- (void)forceUpdateToData:(UIStatusBarData *)arg1 animated:(BOOL)arg2;
@end

@interface SBNotificationCenterController : NSObject

+ (id)sharedInstanceIfExists;
- (BOOL)handleMenuButtonTap;
- (void)dismissAnimated:(BOOL)arg1;
- (BOOL)isVisible;

@end

@interface SBAssistantController : NSObject

+ (id)sharedInstanceIfExists;
+ (BOOL)isAssistantVisible;
- (void)_dismissForMainScreenAnimated:(BOOL)arg1 duration:(double)arg2 completion:(id)arg3;
- (double)_defaultAnimatedDismissDurationForMainScreen;

@end

@interface SBApplication : NSObject {

}

- (id)mainScreenContextHostManager;
- (BOOL)icon:(id)arg1 launchFromLocation:(int)arg2;
- (id)displayIdentifier;
- (id)displayValue:(int)arg1;
- (int)contextID;
- (void)setContextID:(int)arg1;
- (id)displayName;
- (id)bundleIdentifier;
- (void)activate; //New (Added functionality back; Original function simply returns.)
- (BOOL)activationFlag:(unsigned int)arg1;
- (void)addToSlider; //New
- (unsigned int)eventPort;
- (void)rotateToInterfaceOrientation:(int)orientation;//New
- (void)suspend; //new
- (int)statusBarOrientation;
- (BOOL)isRunning;
- (BOOL)supportsApplicationType:(int)arg1;

- (BOOL)forceClassic; //New
- (void)setForceClassic:(BOOL)forceClassic;//New
- (BOOL)isRelaunching; //New
- (void)setRelaunching:(BOOL)relaunching;//New
- (void)relaunch; //New
- (void)launch; //New

@end




@interface SBWorkspace : NSObject

-(void)setCurrentTransaction:(id)arg1;

@end



@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;

- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (void)stopServer;
- (void)runServerOnCurrentThread;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2 error:(id *)arg3;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;

@end

@interface UIWindow()

+ (void)_synchronizeDrawing;

@end

@interface SBIconListView : UIView

- (void)layoutIconsNow;

@end

@interface SBRootFolderView : UIView

- (void)_updateIconListFrames;
- (id)dockView;

@end

@interface SBIconAnimator : NSObject

@property(nonatomic, assign) id delegate;
@property(retain, nonatomic) SBApplication *activatingApp;
@property(retain, nonatomic) SBApplication *deactivatingApp;

@end

@interface SBRootFolderController : NSObject

@property(readonly, nonatomic) SBRootFolderView *contentView;

- (void)setDockOffscreenFraction:(double)arg1;
- (void)willAnimateRotationToInterfaceOrientation:(long long)arg1;
- (void)willRotateToInterfaceOrientation:(long long)arg1;

@end

@interface SBAlertItemsController : NSObject

+ (id)sharedInstance;
- (void)setForceAlertsToPend:(BOOL)arg1 forReason:(id)arg2;

@end

@interface SBUIAnimationController : NSObject

- (void)beginAnimation;
- (void)_setAnimationState:(int)arg1;
- (id)_animationIdentifier;
- (void)_releaseActivationAssertion;
- (void)_cleanupAnimation;


@end

@interface SBRootFolder : NSObject

- (id)dockModel;

@end

@interface SBAppToAppWorkspaceTransaction : NSObject

@property(readonly, nonatomic) SBApplication *toApplication;

- (void)_kickOffActivation;
- (void)_endAnimation;
- (void)animationControllerDidFinishAnimation:(id)arg1;
- (void)_transactionComplete;
- (void)animationController:(id)arg1 willBeginAnimation:(BOOL)arg2;
- (id)_setupAnimationFrom:(id)arg1 to:(id)arg2;
- (void)performToAppStateCleanup;
- (void)_setupAnimation;

@end

@interface SBIconController

+ (id)sharedInstance;
- (void)prepareToRotateFolderAndSlidingViewsToOrientation:(int)arg1;
- (id)dockListView;
- (id)contentView;
- (BOOL)hasOpenFolder;
- (void)_showSearchKeyboardIfNecessary:(BOOL)arg1;
- (BOOL)isShowingSearch;
- (SBRootFolderController*)_rootFolderController;
- (id)rootFolder;
- (void)clearHighlightedIcon;
- (void)_resetRootIconLists;

//New
- (void)addDockToOSViewController;

@end

@interface SBDockIconListView : UIView

- (void)setModel:(id)model;
- (void)layoutIconsNow;
- (id)layoutDelegate;

@end

@interface SBDockView : UIView

- (SBDockIconListView*)dockListView;

@end

@interface SBIconZoomAnimator : NSObject

@end

@interface SBUIAnimationZoomUpApp

- (void)_noteAnimationDidFinish:(BOOL)arg1;
- (void)_cleanupAnimation;
- (void)_noteAnimationDidFinish;
- (void)_notifyDelegateOfCompletion;
- (void)_setAnimationState:(int)arg1;
- (int)_animationState;
- (void)_cancelAnimation;
- (void)_noteZoomDidFinish;
- (void)_setHidden:(BOOL)arg1;


@end 

@interface SBAppToAppTransitionController


-(SBApplication*)activatingApp;
- (void)_cleanupAnimation;
- (void)_cancelAnimation;
- (void)appTransitionViewAnimationDidStop:(id)arg1;

@end


@interface SBIconView : UIImageView

- (SBIcon*)icon;
- (id)_iconImageView;
- (BOOL)isGrabbed;
- (BOOL)isInDock;
- (id)iconImageSnapshot;
- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)highlighted;

@end






@interface SBHostWrapperView : UIView



@end

@interface BKWorkspaceServerManager

-(id)applicationForBundleIdentifier:(NSString*)bundleIdentifier;
-(id)workspaceForApplication:(id)application;
-(id)currentWorkspace;
- (void)_receiveSuspend:(id)arg1;
- (unsigned int)portForBundleIdentifier:(id)arg1;
- (unsigned int)currentEventPort;


@end

@interface BKSWorkspaceActivationTokenFactory : NSObject

+ (id)sharedInstance;
- (id)generateToken;

@end


@interface BKWorkspaceServer

-(void)activate:(id)arg1 withActivation:(id)arg2 withDeactivation:(id)arg3 token:(id)arg4;
- (BOOL)_activate:(id)arg1 activationSettings:(id)arg2 deactivationSettings:(id)arg3 token:(id)arg4 completion:(void*)arg5;
- (id)runningApplications;
- (void)suspend:(id)arg1;
- (void)cancelAllTouches;//New

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

@interface UIApplication(STFUACAdditions)
-(id)displayIdentifier;
- (UIStatusBar*)statusBar;
- (void)_cancelAllTouches;

@end



@interface UIWindow(STFUACAdditions)

-(unsigned int)_contextId;

@end



@interface SBUIController : UIView{

}

+ (id)sharedInstance;
+ (id)zoomViewForContextHostView:(id)arg1 application:(id)arg2 includeStatusBar:(BOOL)arg3 includeBanner:(BOOL)arg4;

- (id)wallpaperView;
- (id)rootView;
- (id)contentView;
- (void)activateApplicationAnimated:(id)arg1;
- (id)systemGestureSnapshotWithIOSurfaceSnapshotOfApp:(id)arg1 includeStatusBar:(BOOL)arg2;
- (id)systemGestureSnapshotForApp:(id)arg1 includeStatusBar:(BOOL)arg2 decodeImage:(BOOL)arg3;
- (void)createFakeSpringBoardStatusBar;
- (id)_fakeSpringBoardStatusBar;
- (void)launchApplicationByGesture:(id)arg1;

//New
- (void)setScaleGestureRecognizer:(SBFluidSlideGestureRecognizer*)recognizer;
- (SBFluidSlideGestureRecognizer*)scaleGestureRecognizer;

@end
