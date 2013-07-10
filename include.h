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
- (id)initWithBundleIdentifier:(id)arg1 queue:(dispatch_queue_s*)arg2;

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
- (void)activate; //New


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


@interface UIApplication(OSAdditions)
-(id)displayIdentifier;


@end



@interface UIWindow(OSAdditions)

-(unsigned int)_contextId;

@end



@interface SBUIController : UIView{

}

-(id)rootView;
- (void)activateApplicationAnimated:(id)arg1;

@end


@interface SBFluidSlideGestureRecognizer : NSObject

-(float)cumulativePercentage;
-(CGPoint)centroidPoint;


@end
