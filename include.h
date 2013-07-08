#define UIApp [UIApplication sharedApplication]
#define DegreesToRadians(x) ((x) * M_PI / 180.0)


@interface BKProcess{

}

-(void)killWithSignal:(int)arg1;


@end



@interface BKApplication{

}

-(int)suspendType;
-(void)setSuspendType:(int)arg1;

@end





@interface SBApplication : NSObject {

}

- (id)displayValue:(int)arg1;
- (int)contextID;
- (void)setContextID:(int)arg1;
- (id)displayName;

- (id)contextHostViewForRequester:(id)arg1 enableAndOrderFront:(BOOL)arg2;

@end







@interface SBHostWrapperView : UIView{

}



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

@end
